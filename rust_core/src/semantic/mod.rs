//! # Luminthor Engine — Semantic Analyzer
//!
//! Performs pre-execution validation of the AST to catch errors early
//! with helpful, educational error messages. Checks include:
//! - Undefined variable references
//! - Basic type compatibility
//! - Function arity validation
//! - Division (and modulo) by a divisor that is always zero
//! - Scope-aware analysis

use std::collections::{HashMap, HashSet};

use crate::ast::*;
use crate::errors::CompileError;

/// Symbol information tracked during analysis.
#[derive(Debug, Clone)]
struct Symbol {
    is_mutable: bool,
    is_function: bool,
    param_count: Option<usize>,
    /// Value known before execution (only for `const` with a constant initializer)
    const_value: Option<ConstNumber>,
}

/// A numeric value that can be computed before execution.
#[derive(Debug, Clone, Copy, PartialEq)]
enum ConstNumber {
    Int(i64),
    Float(f64),
}

impl ConstNumber {
    fn is_zero(self) -> bool {
        match self {
            Self::Int(v) => v == 0,
            Self::Float(v) => v == 0.0,
        }
    }

    fn as_f64(self) -> f64 {
        match self {
            Self::Int(v) => v as f64,
            Self::Float(v) => v,
        }
    }
}

/// The semantic analyzer.
pub struct SemanticAnalyzer {
    /// Stack of scope-level symbol tables
    scopes: Vec<HashMap<String, Symbol>>,
    /// Collected errors
    errors: Vec<CompileError>,
    /// Collected warnings
    warnings: Vec<String>,
    /// Track if we're inside a loop (for break/continue validation)
    loop_depth: usize,
    /// Track if we're inside a function (for return validation)
    function_depth: usize,
}

impl SemanticAnalyzer {
    pub fn new() -> Self {
        Self {
            scopes: vec![HashMap::new()],
            errors: Vec::new(),
            warnings: Vec::new(),
            loop_depth: 0,
            function_depth: 0,
        }
    }

    /// Analyze a complete program.
    pub fn analyze(&mut self, program: &Program) -> Result<(), Vec<CompileError>> {
        // First pass: register top-level function declarations
        for stmt in &program.statements {
            if let StmtKind::FnDecl { name, params, .. } = &stmt.kind {
                self.define_symbol(
                    name.clone(),
                    true,
                    true,
                    Some(params.len()),
                );
            }
        }

        // Add built-in print function
        self.define_symbol("print".to_string(), false, true, Some(1));

        // Second pass: analyze all statements
        for stmt in &program.statements {
            self.analyze_stmt(stmt);
        }

        if self.errors.is_empty() {
            Ok(())
        } else {
            Err(self.errors.clone())
        }
    }

    /// Get warnings (non-fatal issues).
    pub fn warnings(&self) -> &[String] {
        &self.warnings
    }

    // ── Scope Management ─────────────────────────────────────

    fn push_scope(&mut self) {
        self.scopes.push(HashMap::new());
    }

    fn pop_scope(&mut self) {
        // Check for unused variables in the scope being popped
        if let Some(scope) = self.scopes.last() {
            for (name, _symbol) in scope {
                if !name.starts_with('_') {
                    // We could add unused variable warnings here in the future
                }
            }
        }
        if self.scopes.len() > 1 {
            self.scopes.pop();
        }
    }

    fn define_symbol(
        &mut self,
        name: String,
        is_mutable: bool,
        is_function: bool,
        param_count: Option<usize>,
    ) {
        if let Some(scope) = self.scopes.last_mut() {
            scope.insert(
                name.clone(),
                Symbol {
                    is_mutable,
                    is_function,
                    param_count,
                    const_value: None,
                },
            );
        }
    }

    /// Records the value known before execution for the most recent symbol.
    fn set_const_value(&mut self, name: &str, value: Option<ConstNumber>) {
        if let Some(symbol) = self.scopes.last_mut().and_then(|s| s.get_mut(name)) {
            symbol.const_value = value;
        }
    }

    fn lookup_symbol(&self, name: &str) -> Option<&Symbol> {
        for scope in self.scopes.iter().rev() {
            if let Some(symbol) = scope.get(name) {
                return Some(symbol);
            }
        }
        None
    }

    fn find_similar_names(&self, name: &str) -> Vec<String> {
        let mut similar = Vec::new();
        let all_names: HashSet<String> = self
            .scopes
            .iter()
            .flat_map(|s| s.keys().cloned())
            .collect();

        for existing in &all_names {
            if levenshtein_distance(name, existing) <= 2 {
                similar.push(existing.clone());
            }
        }
        similar
    }

    // ── Statement Analysis ───────────────────────────────────

    fn analyze_stmt(&mut self, stmt: &Stmt) {
        match &stmt.kind {
            StmtKind::VarDecl {
                name,
                initializer,
                mutable,
            } => {
                if let Some(expr) = initializer {
                    self.analyze_expr(expr);
                }
                // Only `const` values are guaranteed not to change before use.
                let const_value = if *mutable {
                    None
                } else {
                    initializer.as_ref().and_then(|e| self.const_number(e))
                };
                self.define_symbol(name.clone(), *mutable, false, None);
                self.set_const_value(name, const_value);
            }

            StmtKind::Assignment { target, value } => {
                self.analyze_expr(value);

                match self.lookup_symbol(target) {
                    None => {
                        let similar = self.find_similar_names(target);
                        let suggestion = if similar.is_empty() {
                            None
                        } else {
                            Some(format!("Você quis dizer '{}'?", similar.join("' ou '")))
                        };
                        self.errors.push(CompileError::semantic(
                            format!("A variável '{}' não foi declarada", target),
                            Some(stmt.span.clone()),
                            suggestion,
                        ));
                    }
                    Some(symbol) if !symbol.is_mutable && !symbol.is_function => {
                        self.errors.push(CompileError::semantic(
                            format!("Não é possível atribuir um valor à variável imutável '{}'", target),
                            Some(stmt.span.clone()),
                            Some("Use 'var' no lugar de 'const' para permitir alterações".to_string()),
                        ));
                    }
                    _ => {}
                }
            }

            StmtKind::If {
                condition,
                then_branch,
                else_branch,
            } => {
                self.analyze_expr(condition);
                self.push_scope();
                for s in then_branch {
                    self.analyze_stmt(s);
                }
                self.pop_scope();

                if let Some(else_stmts) = else_branch {
                    self.push_scope();
                    for s in else_stmts {
                        self.analyze_stmt(s);
                    }
                    self.pop_scope();
                }
            }

            StmtKind::While { condition, body } => {
                self.analyze_expr(condition);
                self.loop_depth += 1;
                self.push_scope();
                for s in body {
                    self.analyze_stmt(s);
                }
                self.pop_scope();
                self.loop_depth -= 1;
            }

            StmtKind::For {
                variable,
                iterable,
                body,
            } => {
                self.analyze_expr(iterable);
                self.loop_depth += 1;
                self.push_scope();
                self.define_symbol(variable.clone(), false, false, None);
                for s in body {
                    self.analyze_stmt(s);
                }
                self.pop_scope();
                self.loop_depth -= 1;
            }

            StmtKind::FnDecl { name, params, body } => {
                // Function already registered in first pass
                self.function_depth += 1;
                self.push_scope();
                for param in params {
                    self.define_symbol(param.clone(), true, false, None);
                }
                for s in body {
                    self.analyze_stmt(s);
                }
                self.pop_scope();
                self.function_depth -= 1;

                let _ = name; // suppress unused warning
            }

            StmtKind::Return { value } => {
                if self.function_depth == 0 {
                    self.errors.push(CompileError::semantic(
                        "Não é possível usar 'return' fora de uma função",
                        Some(stmt.span.clone()),
                        None,
                    ));
                }
                if let Some(expr) = value {
                    self.analyze_expr(expr);
                }
            }

            StmtKind::Print { value } => {
                self.analyze_expr(value);
            }

            StmtKind::Break => {
                if self.loop_depth == 0 {
                    self.errors.push(CompileError::semantic(
                        "Não é possível usar 'break' fora de uma repetição",
                        Some(stmt.span.clone()),
                        Some("'break' só pode ser usado em repetições 'while' ou 'for'".to_string()),
                    ));
                }
            }

            StmtKind::Continue => {
                if self.loop_depth == 0 {
                    self.errors.push(CompileError::semantic(
                        "Não é possível usar 'continue' fora de uma repetição",
                        Some(stmt.span.clone()),
                        Some("'continue' só pode ser usado em repetições 'while' ou 'for'".to_string()),
                    ));
                }
            }

            StmtKind::Block { statements } => {
                self.push_scope();
                for s in statements {
                    self.analyze_stmt(s);
                }
                self.pop_scope();
            }

            StmtKind::ExprStmt { expr } => {
                self.analyze_expr(expr);
            }
        }
    }

    // ── Expression Analysis ──────────────────────────────────

    fn analyze_expr(&mut self, expr: &Expr) {
        match &expr.kind {
            ExprKind::Identifier(name) => {
                if self.lookup_symbol(name).is_none() {
                    let similar = self.find_similar_names(name);
                    let suggestion = if similar.is_empty() {
                        None
                    } else {
                        Some(format!("Você quis dizer '{}'?", similar.join("' ou '")))
                    };
                    self.errors.push(CompileError::semantic(
                        format!("A variável '{}' não foi declarada", name),
                        Some(expr.span.clone()),
                        suggestion,
                    ));
                }
            }

            ExprKind::BinaryOp { left, op, right } => {
                self.analyze_expr(left);
                self.analyze_expr(right);
                self.check_division_by_zero(op, right);
            }

            ExprKind::UnaryOp { operand, .. } => {
                self.analyze_expr(operand);
            }

            ExprKind::Call { callee, args } => {
                // Check function exists
                match self.lookup_symbol(callee) {
                    None => {
                        self.errors.push(CompileError::semantic(
                            format!("A função '{}' não foi declarada", callee),
                            Some(expr.span.clone()),
                            None,
                        ));
                    }
                    Some(symbol) if !symbol.is_function => {
                        self.errors.push(CompileError::semantic(
                            format!("'{}' não é uma função", callee),
                            Some(expr.span.clone()),
                            None,
                        ));
                    }
                    Some(symbol) => {
                        // Check arity
                        if let Some(expected) = symbol.param_count {
                            if args.len() != expected {
                                self.errors.push(CompileError::semantic(
                                    format!(
                                        "A função '{}' espera {} argumento(s), mas recebeu {}",
                                        callee, expected, args.len()
                                    ),
                                    Some(expr.span.clone()),
                                    None,
                                ));
                            }
                        }
                    }
                }

                // Analyze arguments
                for arg in args {
                    self.analyze_expr(arg);
                }
            }

            ExprKind::Group(inner) => {
                self.analyze_expr(inner);
            }

            ExprKind::Range { start, end } => {
                self.analyze_expr(start);
                self.analyze_expr(end);
            }

            // Literals don't need analysis
            ExprKind::IntLiteral(_)
            | ExprKind::FloatLiteral(_)
            | ExprKind::StringLiteral(_)
            | ExprKind::BoolLiteral(_)
            | ExprKind::NullLiteral => {}
        }
    }
}

impl SemanticAnalyzer {
    // ── Division by Zero ─────────────────────────────────────

    /// Reports `/` or `%` whose divisor is always zero.
    fn check_division_by_zero(&mut self, op: &BinaryOperator, divisor: &Expr) {
        let message = match op {
            BinaryOperator::Divide => "Divisão por zero: o divisor desta divisão é sempre 0",
            BinaryOperator::Modulo => {
                "Resto da divisão por zero: o divisor desta operação '%' é sempre 0"
            }
            _ => return,
        };

        if self.const_number(divisor).is_some_and(ConstNumber::is_zero) {
            self.errors.push(CompileError::semantic(
                message,
                Some(divisor.span.clone()),
                Some(
                    "Não existe resultado para uma divisão por zero. Troque o divisor \
                     por um valor diferente de 0."
                        .to_string(),
                ),
            ));
        }
    }

    /// Computes the value of a numeric expression when it is known before
    /// execution (literals, `const` values and arithmetic between them).
    fn const_number(&self, expr: &Expr) -> Option<ConstNumber> {
        use ConstNumber::{Float, Int};

        match &expr.kind {
            ExprKind::IntLiteral(v) => Some(Int(*v)),
            ExprKind::FloatLiteral(v) => Some(Float(*v)),
            ExprKind::Group(inner) => self.const_number(inner),
            ExprKind::Identifier(name) => self.lookup_symbol(name)?.const_value,
            ExprKind::UnaryOp { op: UnaryOperator::Negate, operand } => {
                match self.const_number(operand)? {
                    Int(v) => v.checked_neg().map(Int),
                    Float(v) => Some(Float(-v)),
                }
            }
            ExprKind::BinaryOp { left, op, right } => {
                let left = self.const_number(left)?;
                let right = self.const_number(right)?;
                match (left, right) {
                    (Int(a), Int(b)) => match op {
                        BinaryOperator::Add => a.checked_add(b).map(Int),
                        BinaryOperator::Subtract => a.checked_sub(b).map(Int),
                        BinaryOperator::Multiply => a.checked_mul(b).map(Int),
                        BinaryOperator::Divide => a.checked_div(b).map(Int),
                        BinaryOperator::Modulo => a.checked_rem(b).map(Int),
                        _ => None,
                    },
                    _ => {
                        let (a, b) = (left.as_f64(), right.as_f64());
                        match op {
                            BinaryOperator::Add => Some(Float(a + b)),
                            BinaryOperator::Subtract => Some(Float(a - b)),
                            BinaryOperator::Multiply => Some(Float(a * b)),
                            BinaryOperator::Divide if b != 0.0 => Some(Float(a / b)),
                            _ => None,
                        }
                    }
                }
            }
            _ => None,
        }
    }
}

impl Default for SemanticAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

/// Simple Levenshtein distance for "Did you mean?" suggestions.
fn levenshtein_distance(a: &str, b: &str) -> usize {
    let a_len = a.len();
    let b_len = b.len();

    if a_len == 0 { return b_len; }
    if b_len == 0 { return a_len; }

    let mut matrix = vec![vec![0usize; b_len + 1]; a_len + 1];

    for i in 0..=a_len { matrix[i][0] = i; }
    for j in 0..=b_len { matrix[0][j] = j; }

    let a_chars: Vec<char> = a.chars().collect();
    let b_chars: Vec<char> = b.chars().collect();

    for i in 1..=a_len {
        for j in 1..=b_len {
            let cost = if a_chars[i - 1] == b_chars[j - 1] { 0 } else { 1 };
            matrix[i][j] = std::cmp::min(
                std::cmp::min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                ),
                matrix[i - 1][j - 1] + cost,
            );
        }
    }

    matrix[a_len][b_len]
}

/// Convenience function to run semantic analysis.
pub fn analyze(program: &Program) -> Result<(), Vec<CompileError>> {
    let mut analyzer = SemanticAnalyzer::new();
    analyzer.analyze(program)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lexer::tokenize;
    use crate::parser::parse;

    fn analyze_source(source: &str) -> Result<(), Vec<CompileError>> {
        let (tokens, _) = tokenize(source);
        let program = parse(tokens, source).expect("Parse failed");
        analyze(&program)
    }

    #[test]
    fn test_valid_program() {
        let result = analyze_source("var x = 10\nprint(x)");
        assert!(result.is_ok());
    }

    #[test]
    fn test_undefined_variable() {
        let result = analyze_source("print(undefined_var)");
        assert!(result.is_err());
        let errors = result.unwrap_err();
        assert!(errors[0].to_string().contains("não foi declarada"));
    }

    #[test]
    fn test_break_outside_loop() {
        let result = analyze_source("break");
        assert!(result.is_err());
        let errors = result.unwrap_err();
        assert!(errors[0].to_string().contains("fora de uma repetição"));
    }

    #[test]
    fn test_return_outside_function() {
        let result = analyze_source("return 5");
        assert!(result.is_err());
    }

    #[test]
    fn test_break_inside_loop_ok() {
        let result = analyze_source("while true { break }");
        assert!(result.is_ok());
    }

    #[test]
    fn test_return_inside_function_ok() {
        let result = analyze_source("fn foo() { return 1 }");
        assert!(result.is_ok());
    }

    #[test]
    fn test_function_arity_mismatch() {
        let result = analyze_source("fn add(a, b) { return a + b }\nadd(1)");
        assert!(result.is_err());
        let errors = result.unwrap_err();
        assert!(errors[0].to_string().contains("espera 2"));
    }

    fn assert_division_by_zero(source: &str) {
        let errors = analyze_source(source).expect_err(source);
        assert!(
            errors.iter().any(|e| e.to_string().contains("por zero")),
            "esperava erro de divisão por zero em {:?}: {:?}",
            source,
            errors
        );
    }

    #[test]
    fn test_division_by_zero_detected() {
        assert_division_by_zero("var x = 10 / 0");
        assert_division_by_zero("var x = 10.5 / 0.0");
        assert_division_by_zero("var x = 10 % 0");
        assert_division_by_zero("var x = 10 / (2 - 2)");
        assert_division_by_zero("var x = 10 / -0");
        assert_division_by_zero("var x = 4\nx /= 0");
        assert_division_by_zero("const zero = 0\nprint(10 / zero)");
        assert_division_by_zero("const a = 3\nconst b = a - 3\nvar x = 1 / b");
        assert_division_by_zero("fn f(n) { return n / 0 }");
    }

    #[test]
    fn test_division_by_nonzero_ok() {
        assert!(analyze_source("var x = 10 / 2").is_ok());
        assert!(analyze_source("var x = 10 / (1 / 2.0)").is_ok());
        // `var` may change before use, so it is only checked at runtime.
        assert!(analyze_source("var z = 0\nz = 5\nprint(10 / z)").is_ok());
        assert!(analyze_source("fn f(n) { return 10 / n }\nprint(f(2))").is_ok());
    }

    #[test]
    fn test_division_by_zero_span_points_to_divisor() {
        let errors = analyze_source("var x = 10 / 0").unwrap_err();
        let span = errors[0].span().expect("span");
        assert_eq!((span.line, span.column), (1, 14));
    }

    #[test]
    fn test_levenshtein() {
        assert_eq!(levenshtein_distance("kitten", "sitting"), 3);
        assert_eq!(levenshtein_distance("", "abc"), 3);
        assert_eq!(levenshtein_distance("abc", "abc"), 0);
    }
}
