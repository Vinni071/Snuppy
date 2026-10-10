//! # Luminthor Engine — Tree-Walking Interpreter
//!
//! Executes AST nodes directly, producing an execution trace that
//! captures the complete state at each step for didactic visualization.
//!
//! The interpreter supports:
//! - Variables (mutable and immutable)
//! - Arithmetic, comparison, and logical operators
//! - If/else conditionals
//! - While and for loops
//! - Functions with lexical scoping
//! - Print output
//! - Break/continue control flow
//! - Step-by-step execution with full state snapshots

pub mod environment;

use std::collections::HashMap;

use environment::{Environment, ScopeSnapshot, Value};
use crate::ast::*;
use crate::errors::CompileError;
use serde::{Deserialize, Serialize};

/// A single step in the execution trace.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionStep {
    /// Line number being executed (1-indexed)
    pub line: usize,
    /// Column number (1-indexed)
    pub column: usize,
    /// What action was performed
    pub action: String,
    /// Description of the action for UI display
    pub description: String,
    /// All variables and their values at this point
    pub variables: HashMap<String, Value>,
    /// Variables grouped by scope, preserving shadowed names.
    pub scopes: Vec<ScopeSnapshot>,
    /// Current scope depth
    pub scope_depth: usize,
    /// Current call stack (function names)
    pub call_stack: Vec<String>,
    /// Any output produced at this step
    pub output: Option<String>,
}

/// Result of interpreting a program.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InterpreterResult {
    /// Captured standard output
    pub output: String,
    /// All execution steps for visualization
    pub execution_trace: Vec<ExecutionStep>,
    /// Final memory state
    pub memory_state: HashMap<String, Value>,
    /// Errors encountered during execution
    pub errors: Vec<CompileError>,
}

/// Control flow signals for break/continue/return.
enum ControlFlow {
    None,
    Break,
    Continue,
    Return(Value),
}

/// The tree-walking interpreter.
pub struct Interpreter {
    env: Environment,
    output: Vec<String>,
    trace: Vec<ExecutionStep>,
    call_stack: Vec<String>,
    /// Store function bodies for later invocation
    functions: HashMap<String, (Vec<String>, Vec<Stmt>)>,
    /// Maximum number of execution steps (prevents infinite loops)
    max_steps: usize,
    step_count: usize,
}

impl Interpreter {
    pub fn new() -> Self {
        Self {
            env: Environment::new(),
            output: Vec::new(),
            trace: Vec::new(),
            call_stack: vec!["<main>".to_string()],
            functions: HashMap::new(),
            max_steps: 10_000,
            step_count: 0,
        }
    }

    /// Set the maximum number of execution steps.
    pub fn with_max_steps(mut self, max: usize) -> Self {
        self.max_steps = max;
        self
    }

    /// Interpret a complete program.
    pub fn interpret(&mut self, program: &Program) -> InterpreterResult {
        let mut errors = Vec::new();

        // First pass: register all function declarations
        for stmt in &program.statements {
            if let StmtKind::FnDecl { name, params, body } = &stmt.kind {
                self.functions
                    .insert(name.clone(), (params.clone(), body.clone()));
            }
        }

        // Second pass: execute statements
        for stmt in &program.statements {
            if let StmtKind::FnDecl { .. } = &stmt.kind {
                continue; // Already registered
            }

            match self.execute_stmt(stmt) {
                Ok(ControlFlow::None) => {}
                Ok(ControlFlow::Return(_)) => {
                    errors.push(CompileError::runtime(
                        "Não é possível usar 'return' fora de uma função",
                        Some(stmt.span.clone()),
                        self.call_stack.clone(),
                    ));
                    break;
                }
                Ok(ControlFlow::Break) => {
                    errors.push(CompileError::runtime(
                        "Não é possível usar 'break' fora de uma repetição",
                        Some(stmt.span.clone()),
                        self.call_stack.clone(),
                    ));
                    break;
                }
                Ok(ControlFlow::Continue) => {
                    errors.push(CompileError::runtime(
                        "Não é possível usar 'continue' fora de uma repetição",
                        Some(stmt.span.clone()),
                        self.call_stack.clone(),
                    ));
                    break;
                }
                Err(e) => {
                    errors.push(e);
                    break;
                }
            }
        }

        InterpreterResult {
            output: self.output.join(""),
            execution_trace: self.trace.clone(),
            memory_state: self.env.snapshot_all(),
            errors,
        }
    }

    /// Record an execution step for the trace.
    fn record_step(&mut self, span: &Span, action: &str, description: &str) {
        self.step_count += 1;
        self.trace.push(ExecutionStep {
            line: span.line,
            column: span.column,
            action: action.to_string(),
            description: description.to_string(),
            variables: self.env.snapshot_all(),
            scopes: self.env.snapshot_by_scope(),
            scope_depth: self.env.depth(),
            call_stack: self.call_stack.clone(),
            output: None,
        });
    }

    /// Check if we've exceeded the step limit.
    fn check_step_limit(&self, span: &Span) -> Result<(), CompileError> {
        if self.step_count >= self.max_steps {
            Err(CompileError::runtime(
                format!(
                    "Limite de execução atingido ({} passos). Verifique se há uma repetição infinita.",
                    self.max_steps
                ),
                Some(span.clone()),
                self.call_stack.clone(),
            ))
        } else {
            Ok(())
        }
    }

    // ── Statement Execution ─────────────────────────────────

    fn execute_stmt(&mut self, stmt: &Stmt) -> Result<ControlFlow, CompileError> {
        self.check_step_limit(&stmt.span)?;

        match &stmt.kind {
            StmtKind::VarDecl {
                name,
                initializer,
                mutable: _,
            } => {
                let value = if let Some(expr) = initializer {
                    self.eval_expr(expr)?
                } else {
                    Value::Null
                };

                let description = format!("Declarar variável '{}' = {}", name, value.display());
                self.env.define(name.clone(), value);
                self.record_step(
                    &stmt.span,
                    "var_decl",
                    &description,
                );
                Ok(ControlFlow::None)
            }

            StmtKind::Assignment { target, value } => {
                let val = self.eval_expr(value)?;

                if !self.env.assign(target, val.clone()) {
                    return Err(CompileError::runtime(
                        format!("A variável '{}' não foi declarada", target),
                        Some(stmt.span.clone()),
                        self.call_stack.clone(),
                    ));
                }

                self.record_step(
                    &stmt.span,
                    "assignment",
                    &format!("Atribuir '{}' = {}", target, val.display()),
                );

                Ok(ControlFlow::None)
            }

            StmtKind::If {
                condition,
                then_branch,
                else_branch,
            } => {
                let cond_val = self.eval_expr(condition)?;
                let is_true = cond_val.is_truthy();

                self.record_step(
                    &stmt.span,
                    "if_eval",
                    &format!(
                        "Avaliar condição de if: {} → {}",
                        cond_val.display(),
                        if is_true { "verdadeira (executar bloco)" } else { "falsa (pular bloco)" }
                    ),
                );

                if is_true {
                    self.env.push_scope(false);
                    let result = self.execute_block(then_branch)?;
                    self.env.pop_scope();
                    if !matches!(result, ControlFlow::None) {
                        return Ok(result);
                    }
                } else if let Some(else_stmts) = else_branch {
                    self.env.push_scope(false);
                    let result = self.execute_block(else_stmts)?;
                    self.env.pop_scope();
                    if !matches!(result, ControlFlow::None) {
                        return Ok(result);
                    }
                }

                Ok(ControlFlow::None)
            }

            StmtKind::While { condition, body } => {
                loop {
                    self.check_step_limit(&stmt.span)?;
                    let cond_val = self.eval_expr(condition)?;
                    let is_true = cond_val.is_truthy();

                    self.record_step(
                        &stmt.span,
                        "while_check",
                        &format!(
                            "Condição de while: {} → {}",
                            cond_val.display(),
                            if is_true { "repetir" } else { "sair" }
                        ),
                    );

                    if !is_true {
                        break;
                    }

                    self.env.push_scope(false);
                    let result = self.execute_block(body)?;
                    self.env.pop_scope();

                    match result {
                        ControlFlow::Break => break,
                        ControlFlow::Continue => continue,
                        ControlFlow::Return(v) => return Ok(ControlFlow::Return(v)),
                        ControlFlow::None => {}
                    }
                }

                Ok(ControlFlow::None)
            }

            StmtKind::For {
                variable,
                iterable,
                body,
            } => {
                // For now, support range expressions
                let iter_val = self.eval_expr(iterable)?;

                match iter_val {
                    Value::Int(end) => {
                        // Simple range: for x in N → iterates 0..N
                        for i in 0..end {
                            self.check_step_limit(&stmt.span)?;

                            self.env.push_scope(false);
                            self.env.define(variable.clone(), Value::Int(i));

                            self.record_step(
                                &stmt.span,
                                "for_iter",
                                &format!("Repetição for: {} = {}", variable, i),
                            );

                            let result = self.execute_block(body)?;
                            self.env.pop_scope();

                            match result {
                                ControlFlow::Break => break,
                                ControlFlow::Continue => continue,
                                ControlFlow::Return(v) => return Ok(ControlFlow::Return(v)),
                                ControlFlow::None => {}
                            }
                        }
                    }
                    _ => {
                        return Err(CompileError::runtime(
                            format!("Não é possível iterar sobre um valor do tipo {}", iter_val.type_name()),
                            Some(stmt.span.clone()),
                            self.call_stack.clone(),
                        ));
                    }
                }

                Ok(ControlFlow::None)
            }

            StmtKind::FnDecl { name, params, body } => {
                // Register function (may already be registered in first pass)
                self.functions
                    .insert(name.clone(), (params.clone(), body.clone()));

                self.record_step(
                    &stmt.span,
                    "fn_decl",
                    &format!("Definir função '{}({})'", name, params.join(", ")),
                );

                Ok(ControlFlow::None)
            }

            StmtKind::Return { value } => {
                let val = if let Some(expr) = value {
                    self.eval_expr(expr)?
                } else {
                    Value::Null
                };

                self.record_step(
                    &stmt.span,
                    "return",
                    &format!("Retornar {}", val.display()),
                );

                Ok(ControlFlow::Return(val))
            }

            StmtKind::Print { value } => {
                let val = self.eval_expr(value)?;
                let output_str = format!("{}\n", val.display());

                self.output.push(output_str.clone());

                // Record step with output
                self.step_count += 1;
                self.trace.push(ExecutionStep {
                    line: stmt.span.line,
                    column: stmt.span.column,
                    action: "print".to_string(),
                    description: format!("Imprimir: {}", val.display()),
                    variables: self.env.snapshot_all(),
                    scopes: self.env.snapshot_by_scope(),
                    scope_depth: self.env.depth(),
                    call_stack: self.call_stack.clone(),
                    output: Some(output_str),
                });

                Ok(ControlFlow::None)
            }

            StmtKind::Break => {
                self.record_step(&stmt.span, "break", "Sair da repetição");
                Ok(ControlFlow::Break)
            }

            StmtKind::Continue => {
                self.record_step(&stmt.span, "continue", "Avançar para a próxima iteração");
                Ok(ControlFlow::Continue)
            }

            StmtKind::Block { statements } => {
                self.env.push_scope(false);
                let result = self.execute_block(statements)?;
                self.env.pop_scope();
                Ok(result)
            }

            StmtKind::ExprStmt { expr } => {
                self.eval_expr(expr)?;
                Ok(ControlFlow::None)
            }
        }
    }

    fn execute_block(&mut self, statements: &[Stmt]) -> Result<ControlFlow, CompileError> {
        for stmt in statements {
            let result = self.execute_stmt(stmt)?;
            if !matches!(result, ControlFlow::None) {
                return Ok(result);
            }
        }
        Ok(ControlFlow::None)
    }

    // ── Expression Evaluation ─────────────────────────────────

    fn eval_expr(&mut self, expr: &Expr) -> Result<Value, CompileError> {
        match &expr.kind {
            ExprKind::IntLiteral(v) => Ok(Value::Int(*v)),
            ExprKind::FloatLiteral(v) => Ok(Value::Float(*v)),
            ExprKind::StringLiteral(v) => Ok(Value::String(v.clone())),
            ExprKind::BoolLiteral(v) => Ok(Value::Bool(*v)),
            ExprKind::NullLiteral => Ok(Value::Null),

            ExprKind::Identifier(name) => {
                self.env.get(name).cloned().ok_or_else(|| {
                    CompileError::runtime(
                        format!("A variável '{}' não foi declarada", name),
                        Some(expr.span.clone()),
                        self.call_stack.clone(),
                    )
                })
            }

            ExprKind::BinaryOp { left, op, right } => {
                let lval = self.eval_expr(left)?;
                let rval = self.eval_expr(right)?;
                self.eval_binary_op(&lval, op, &rval, &expr.span)
            }

            ExprKind::UnaryOp { op, operand } => {
                let val = self.eval_expr(operand)?;
                self.eval_unary_op(op, &val, &expr.span)
            }

            ExprKind::Call { callee, args } => {
                let arg_values: Vec<Value> = args
                    .iter()
                    .map(|a| self.eval_expr(a))
                    .collect::<Result<Vec<_>, _>>()?;

                self.call_function(callee, &arg_values, &expr.span)
            }

            ExprKind::Group(inner) => self.eval_expr(inner),

            ExprKind::Range { start: _, end } => {
                // Range expressions evaluated lazily during for-loop
                // For now, return the end value (simple range 0..N)
                self.eval_expr(end)
            }
        }
    }

    fn eval_binary_op(
        &self,
        left: &Value,
        op: &BinaryOperator,
        right: &Value,
        span: &Span,
    ) -> Result<Value, CompileError> {
        match (left, op, right) {
            // Integer arithmetic
            (Value::Int(a), BinaryOperator::Add, Value::Int(b)) => Ok(Value::Int(a + b)),
            (Value::Int(a), BinaryOperator::Subtract, Value::Int(b)) => Ok(Value::Int(a - b)),
            (Value::Int(a), BinaryOperator::Multiply, Value::Int(b)) => Ok(Value::Int(a * b)),
            (Value::Int(a), BinaryOperator::Divide, Value::Int(b)) => {
                if *b == 0 {
                    Err(CompileError::runtime(
                        "Divisão por zero",
                        Some(span.clone()),
                        self.call_stack.clone(),
                    ))
                } else {
                    Ok(Value::Int(a / b))
                }
            }
            (Value::Int(a), BinaryOperator::Modulo, Value::Int(b)) => {
                if *b == 0 {
                    Err(CompileError::runtime(
                        "Resto da divisão por zero",
                        Some(span.clone()),
                        self.call_stack.clone(),
                    ))
                } else {
                    Ok(Value::Int(a % b))
                }
            }

            // Float arithmetic
            (Value::Float(a), BinaryOperator::Add, Value::Float(b)) => Ok(Value::Float(a + b)),
            (Value::Float(a), BinaryOperator::Subtract, Value::Float(b)) => Ok(Value::Float(a - b)),
            (Value::Float(a), BinaryOperator::Multiply, Value::Float(b)) => Ok(Value::Float(a * b)),
            (Value::Float(a), BinaryOperator::Divide, Value::Float(b)) => {
                if *b == 0.0 {
                    Err(CompileError::runtime(
                        "Divisão por zero",
                        Some(span.clone()),
                        self.call_stack.clone(),
                    ))
                } else {
                    Ok(Value::Float(a / b))
                }
            }

            // Mixed int/float arithmetic (promote to float)
            (Value::Int(a), BinaryOperator::Add, Value::Float(b)) => Ok(Value::Float(*a as f64 + b)),
            (Value::Float(a), BinaryOperator::Add, Value::Int(b)) => Ok(Value::Float(a + *b as f64)),
            (Value::Int(a), BinaryOperator::Subtract, Value::Float(b)) => Ok(Value::Float(*a as f64 - b)),
            (Value::Float(a), BinaryOperator::Subtract, Value::Int(b)) => Ok(Value::Float(a - *b as f64)),
            (Value::Int(a), BinaryOperator::Multiply, Value::Float(b)) => Ok(Value::Float(*a as f64 * b)),
            (Value::Float(a), BinaryOperator::Multiply, Value::Int(b)) => Ok(Value::Float(a * *b as f64)),
            (Value::Int(a), BinaryOperator::Divide, Value::Float(b)) => {
                if *b == 0.0 {
                    Err(CompileError::runtime("Divisão por zero", Some(span.clone()), self.call_stack.clone()))
                } else {
                    Ok(Value::Float(*a as f64 / b))
                }
            }
            (Value::Float(a), BinaryOperator::Divide, Value::Int(b)) => {
                if *b == 0 {
                    Err(CompileError::runtime("Divisão por zero", Some(span.clone()), self.call_stack.clone()))
                } else {
                    Ok(Value::Float(a / *b as f64))
                }
            }

            // String concatenation
            (Value::String(a), BinaryOperator::Add, Value::String(b)) => {
                Ok(Value::String(format!("{}{}", a, b)))
            }
            (Value::String(a), BinaryOperator::Add, other) => {
                Ok(Value::String(format!("{}{}", a, other.display())))
            }
            (other, BinaryOperator::Add, Value::String(b)) => {
                Ok(Value::String(format!("{}{}", other.display(), b)))
            }

            // Integer comparisons
            (Value::Int(a), BinaryOperator::Equal, Value::Int(b)) => Ok(Value::Bool(a == b)),
            (Value::Int(a), BinaryOperator::NotEqual, Value::Int(b)) => Ok(Value::Bool(a != b)),
            (Value::Int(a), BinaryOperator::Less, Value::Int(b)) => Ok(Value::Bool(a < b)),
            (Value::Int(a), BinaryOperator::Greater, Value::Int(b)) => Ok(Value::Bool(a > b)),
            (Value::Int(a), BinaryOperator::LessEqual, Value::Int(b)) => Ok(Value::Bool(a <= b)),
            (Value::Int(a), BinaryOperator::GreaterEqual, Value::Int(b)) => Ok(Value::Bool(a >= b)),

            // Float comparisons
            (Value::Float(a), BinaryOperator::Equal, Value::Float(b)) => Ok(Value::Bool(a == b)),
            (Value::Float(a), BinaryOperator::NotEqual, Value::Float(b)) => Ok(Value::Bool(a != b)),
            (Value::Float(a), BinaryOperator::Less, Value::Float(b)) => Ok(Value::Bool(a < b)),
            (Value::Float(a), BinaryOperator::Greater, Value::Float(b)) => Ok(Value::Bool(a > b)),
            (Value::Float(a), BinaryOperator::LessEqual, Value::Float(b)) => Ok(Value::Bool(a <= b)),
            (Value::Float(a), BinaryOperator::GreaterEqual, Value::Float(b)) => Ok(Value::Bool(a >= b)),

            // Mixed comparisons
            (Value::Int(a), BinaryOperator::Less, Value::Float(b)) => Ok(Value::Bool((*a as f64) < *b)),
            (Value::Float(a), BinaryOperator::Less, Value::Int(b)) => Ok(Value::Bool(*a < *b as f64)),
            (Value::Int(a), BinaryOperator::Greater, Value::Float(b)) => Ok(Value::Bool((*a as f64) > *b)),
            (Value::Float(a), BinaryOperator::Greater, Value::Int(b)) => Ok(Value::Bool(*a > *b as f64)),
            (Value::Int(a), BinaryOperator::LessEqual, Value::Float(b)) => Ok(Value::Bool((*a as f64) <= *b)),
            (Value::Float(a), BinaryOperator::LessEqual, Value::Int(b)) => Ok(Value::Bool(*a <= *b as f64)),
            (Value::Int(a), BinaryOperator::GreaterEqual, Value::Float(b)) => Ok(Value::Bool((*a as f64) >= *b)),
            (Value::Float(a), BinaryOperator::GreaterEqual, Value::Int(b)) => Ok(Value::Bool(*a >= *b as f64)),
            (Value::Int(a), BinaryOperator::Equal, Value::Float(b)) => Ok(Value::Bool((*a as f64) == *b)),
            (Value::Float(a), BinaryOperator::Equal, Value::Int(b)) => Ok(Value::Bool(*a == *b as f64)),
            (Value::Int(a), BinaryOperator::NotEqual, Value::Float(b)) => Ok(Value::Bool((*a as f64) != *b)),
            (Value::Float(a), BinaryOperator::NotEqual, Value::Int(b)) => Ok(Value::Bool(*a != *b as f64)),

            // String comparisons
            (Value::String(a), BinaryOperator::Equal, Value::String(b)) => Ok(Value::Bool(a == b)),
            (Value::String(a), BinaryOperator::NotEqual, Value::String(b)) => Ok(Value::Bool(a != b)),

            // Boolean comparisons
            (Value::Bool(a), BinaryOperator::Equal, Value::Bool(b)) => Ok(Value::Bool(a == b)),
            (Value::Bool(a), BinaryOperator::NotEqual, Value::Bool(b)) => Ok(Value::Bool(a != b)),

            // Logical operators
            (l, BinaryOperator::And, r) => Ok(Value::Bool(l.is_truthy() && r.is_truthy())),
            (l, BinaryOperator::Or, r) => Ok(Value::Bool(l.is_truthy() || r.is_truthy())),

            // Null equality
            (Value::Null, BinaryOperator::Equal, Value::Null) => Ok(Value::Bool(true)),
            (Value::Null, BinaryOperator::NotEqual, Value::Null) => Ok(Value::Bool(false)),
            (_, BinaryOperator::Equal, Value::Null) => Ok(Value::Bool(false)),
            (Value::Null, BinaryOperator::Equal, _) => Ok(Value::Bool(false)),
            (_, BinaryOperator::NotEqual, Value::Null) => Ok(Value::Bool(true)),
            (Value::Null, BinaryOperator::NotEqual, _) => Ok(Value::Bool(true)),

            _ => Err(CompileError::runtime(
                format!(
                    "Não é possível aplicar o operador '{}' aos tipos {} e {}",
                    op.symbol(),
                    left.type_name(),
                    right.type_name()
                ),
                Some(span.clone()),
                self.call_stack.clone(),
            )),
        }
    }

    fn eval_unary_op(
        &self,
        op: &UnaryOperator,
        val: &Value,
        span: &Span,
    ) -> Result<Value, CompileError> {
        match (op, val) {
            (UnaryOperator::Negate, Value::Int(v)) => Ok(Value::Int(-v)),
            (UnaryOperator::Negate, Value::Float(v)) => Ok(Value::Float(-v)),
            (UnaryOperator::Not, v) => Ok(Value::Bool(!v.is_truthy())),
            _ => Err(CompileError::runtime(
                format!(
                    "Não é possível aplicar o operador '{}' ao tipo {}",
                    op.symbol(),
                    val.type_name()
                ),
                Some(span.clone()),
                self.call_stack.clone(),
            )),
        }
    }

    fn call_function(
        &mut self,
        name: &str,
        args: &[Value],
        span: &Span,
    ) -> Result<Value, CompileError> {
        // Look up the function
        let (params, body) = self.functions.get(name).cloned().ok_or_else(|| {
            CompileError::runtime(
                format!("A função '{}' não foi declarada", name),
                Some(span.clone()),
                self.call_stack.clone(),
            )
        })?;

        // Check arity
        if args.len() != params.len() {
            return Err(CompileError::runtime(
                format!(
                    "A função '{}' espera {} argumento(s), mas recebeu {}",
                    name,
                    params.len(),
                    args.len()
                ),
                Some(span.clone()),
                self.call_stack.clone(),
            ));
        }

        // Push function scope
        self.call_stack.push(name.to_string());
        self.env.push_scope(true);

        // Bind parameters
        for (param, arg) in params.iter().zip(args.iter()) {
            self.env.define(param.clone(), arg.clone());
        }

        self.record_step(
            span,
            "fn_call",
            &format!(
                "Chamar {}({})",
                name,
                args.iter()
                    .map(|a| a.display())
                    .collect::<Vec<_>>()
                    .join(", ")
            ),
        );

        // Execute function body
        let result = self.execute_block(&body);

        // Pop function scope
        self.env.pop_scope();
        self.call_stack.pop();

        match result {
            Ok(ControlFlow::Return(val)) => Ok(val),
            Ok(ControlFlow::None) => Ok(Value::Null),
            Ok(ControlFlow::Break) => Err(CompileError::runtime(
                "Não é possível propagar 'break' para fora de uma função",
                Some(span.clone()),
                self.call_stack.clone(),
            )),
            Ok(ControlFlow::Continue) => Err(CompileError::runtime(
                "Não é possível propagar 'continue' para fora de uma função",
                Some(span.clone()),
                self.call_stack.clone(),
            )),
            Err(e) => Err(e),
        }
    }
}

impl Default for Interpreter {
    fn default() -> Self {
        Self::new()
    }
}

/// Convenience function to interpret source code from the pipeline.
pub fn interpret(program: &Program) -> InterpreterResult {
    let mut interpreter = Interpreter::new();
    interpreter.interpret(program)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lexer::tokenize;
    use crate::parser::parse;

    fn run(source: &str) -> InterpreterResult {
        let (tokens, _) = tokenize(source);
        let program = parse(tokens, source).expect("Parse failed");
        let mut interpreter = Interpreter::new();
        interpreter.interpret(&program)
    }

    #[test]
    fn test_var_and_print() {
        let result = run(r#"var x = 42
print(x)"#);
        assert!(result.errors.is_empty(), "Errors: {:?}", result.errors);
        assert_eq!(result.output.trim(), "42");
    }

    #[test]
    fn test_arithmetic() {
        let result = run("var x = 2 + 3 * 4\nprint(x)");
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "14");
    }

    #[test]
    fn test_string_concat() {
        let result = run(r#"var msg = "hello" + " " + "world"
print(msg)"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "hello world");
    }

    #[test]
    fn test_if_true() {
        let result = run(r#"var x = 10
if x < 20 {
    print("yes")
}"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "yes");
    }

    #[test]
    fn test_if_false_else() {
        let result = run(r#"var x = 30
if x < 20 {
    print("small")
} else {
    print("big")
}"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "big");
    }

    #[test]
    fn test_while_loop() {
        let result = run(r#"var i = 0
while i < 5 {
    i = i + 1
}
print(i)"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "5");
    }

    #[test]
    fn test_function() {
        let result = run(r#"fn add(a, b) {
    return a + b
}
var result = add(3, 4)
print(result)"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "7");
    }

    #[test]
    fn test_recursion() {
        let result = run(r#"fn factorial(n) {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}
print(factorial(5))"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "120");
    }

    #[test]
    fn test_execution_trace() {
        let result = run("var x = 10\nvar y = 20");
        assert!(result.errors.is_empty());
        assert!(!result.execution_trace.is_empty());
        // Should have at least 2 steps (one per var_decl)
        assert!(result.execution_trace.len() >= 2);
    }

    #[test]
    fn test_division_by_zero() {
        let result = run("var x = 10 / 0");
        assert!(!result.errors.is_empty());
        assert!(result.errors[0].to_string().contains("Divisão por zero"));
    }

    #[test]
    fn test_undefined_variable() {
        let result = run("print(undefined_var)");
        assert!(!result.errors.is_empty());
        assert!(result.errors[0].to_string().contains("não foi declarada"));
    }

    #[test]
    fn test_scope_isolation() {
        let result = run(r#"var x = 1
if true {
    var y = 2
    print(y)
}
print(x)"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output, "2\n1\n");
    }

    #[test]
    fn test_infinite_loop_protection() {
        let mut interp = Interpreter::new().with_max_steps(100);
        let (tokens, _) = tokenize("while true { var x = 1 }");
        let program = parse(tokens, "while true { var x = 1 }").unwrap();
        let result = interp.interpret(&program);
        assert!(!result.errors.is_empty());
        assert!(result.errors[0].to_string().contains("Limite de execução"));
    }

    #[test]
    fn test_break_in_loop() {
        let result = run(r#"var i = 0
while true {
    if i == 3 {
        break
    }
    i = i + 1
}
print(i)"#);
        assert!(result.errors.is_empty());
        assert_eq!(result.output.trim(), "3");
    }

    #[test]
    fn test_memory_state() {
        let result = run("var x = 10\nvar y = 20\nvar z = x + y");
        assert!(result.errors.is_empty());
        assert_eq!(result.memory_state.get("x"), Some(&Value::Int(10)));
        assert_eq!(result.memory_state.get("y"), Some(&Value::Int(20)));
        assert_eq!(result.memory_state.get("z"), Some(&Value::Int(30)));
    }
}
