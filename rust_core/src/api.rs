//! # Luminthor Engine — Public API
//!
//! The unified public API layer that the Flutter app (via FRB) and the CLI
//! both use. All functions return fully serializable results suitable
//! for JSON transmission to the Flutter UI.

use std::collections::HashMap;
use serde::{Deserialize, Serialize};

use crate::ast::AstNodeView;
use crate::errors::CompileError;
use crate::interpreter::environment::Value;
use crate::interpreter::{ExecutionStep, InterpreterResult};
use crate::lexer::TokenInfo;

/// The complete result of processing source code through the pipeline.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompileResult {
    /// Tokens produced by the lexer
    pub tokens: Vec<TokenInfo>,
    /// AST tree view for visualization (None if parsing failed)
    pub ast: Option<AstNodeView>,
    /// Program output (stdout)
    pub output: String,
    /// All errors from any pipeline stage
    pub errors: Vec<CompileError>,
    /// Final memory state after execution
    pub memory_state: HashMap<String, Value>,
    /// Full execution trace for step-by-step visualization
    pub execution_trace: Vec<ExecutionStep>,
    /// Warnings from semantic analysis
    pub warnings: Vec<String>,
    /// Whether execution completed successfully
    pub success: bool,
}

/// Process source code through the complete pipeline:
/// Lexer → Parser → Semantic Analysis → Interpreter
pub fn process_source(source: &str) -> CompileResult {
    let mut all_errors: Vec<CompileError> = Vec::new();

    // ── Stage 1: Lexing ──────────────────────────────────────
    let (tokens, lex_errors) = crate::lexer::tokenize_with_diagnostics(source);
    all_errors.extend(lex_errors);

    // If there are lexer errors, we can still try parsing
    // but report the errors

    // ── Stage 2: Parsing ─────────────────────────────────────
    let program = match crate::parser::parse(tokens.clone(), source) {
        Ok(program) => Some(program),
        Err(parse_errors) => {
            all_errors.extend(parse_errors);
            None
        }
    };

    // If parsing failed, return early with tokens and errors
    let program = match program {
        Some(p) => p,
        None => {
            return CompileResult {
                tokens,
                ast: None,
                output: String::new(),
                errors: all_errors,
                memory_state: HashMap::new(),
                execution_trace: Vec::new(),
                warnings: Vec::new(),
                success: false,
            };
        }
    };

    // Generate AST view
    let ast_view = AstNodeView::from_program(&program);

    // ── Stage 3: Semantic Analysis ───────────────────────────
    let semantic_warnings;
    match crate::semantic::analyze(&program) {
        Ok(()) => {
            semantic_warnings = Vec::new();
        }
        Err(semantic_errors) => {
            all_errors.extend(semantic_errors);
            // Still try to run — some semantic errors are non-fatal
            semantic_warnings = Vec::new();
        }
    }

    // If there are critical errors, don't run
    if !all_errors.is_empty() {
        return CompileResult {
            tokens,
            ast: Some(ast_view),
            output: String::new(),
            errors: all_errors,
            memory_state: HashMap::new(),
            execution_trace: Vec::new(),
            warnings: semantic_warnings,
            success: false,
        };
    }

    // ── Stage 4: Interpretation ──────────────────────────────
    let InterpreterResult {
        output,
        execution_trace,
        memory_state,
        errors: runtime_errors,
    } = crate::interpreter::interpret(&program);

    let success = runtime_errors.is_empty();
    all_errors.extend(runtime_errors);

    CompileResult {
        tokens,
        ast: Some(ast_view),
        output,
        errors: all_errors,
        memory_state,
        execution_trace,
        warnings: semantic_warnings,
        success,
    }
}

/// Tokenize source code only (for the token viewer).
pub fn tokenize_only(source: &str) -> (Vec<TokenInfo>, Vec<String>) {
    crate::lexer::tokenize(source)
}

/// Parse source code and return the AST view (for the AST viewer).
pub fn parse_only(source: &str) -> Result<AstNodeView, Vec<CompileError>> {
    let (tokens, errors) = crate::lexer::tokenize_with_diagnostics(source);
    if !errors.is_empty() {
        return Err(errors);
    }
    let program = crate::parser::parse(tokens, source)?;
    Ok(AstNodeView::from_program(&program))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_full_pipeline_success() {
        let result = process_source("var x = 10\nprint(x)");
        assert!(result.success, "Errors: {:?}", result.errors);
        assert_eq!(result.output.trim(), "10");
        assert!(!result.tokens.is_empty());
        assert!(result.ast.is_some());
        assert!(!result.execution_trace.is_empty());
    }

    #[test]
    fn test_full_pipeline_error() {
        let result = process_source("var = oops");
        assert!(!result.success);
        assert!(!result.errors.is_empty());
    }

    #[test]
    fn test_complex_program() {
        let source = r#"
fn fibonacci(n) {
    if n <= 1 {
        return n
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

var i = 0
while i < 8 {
    print(fibonacci(i))
    i = i + 1
}
"#;
        let result = process_source(source);
        assert!(result.success, "Errors: {:?}", result.errors);
        let lines: Vec<&str> = result.output.trim().lines().collect();
        assert_eq!(lines, vec!["0", "1", "1", "2", "3", "5", "8", "13"]);
    }

    #[test]
    fn test_tokenize_only() {
        let (tokens, errors) = tokenize_only("var x = 42");
        assert!(errors.is_empty());
        assert_eq!(tokens.len(), 4);
    }

    #[test]
    fn test_parse_only() {
        let ast = parse_only("var x = 1 + 2").unwrap();
        assert_eq!(ast.label, "Program");
        assert!(!ast.children.is_empty());
    }

    #[test]
    fn lexical_diagnostics_keep_unicode_locations_and_byte_spans() {
        let source = "print(\"á\"); @\n  é";
        let result = process_source(source);
        assert!(!result.success);
        let errors: Vec<_> = result.errors.iter().filter(|e| {
            matches!(e, CompileError::LexerError { .. })
        }).collect();
        assert_eq!(errors.len(), 2);
        let first = errors[0].span().unwrap();
        assert_eq!((first.line, first.column), (1, 13));
        assert_eq!(&source[first.start..first.end], "@");
        let second = errors[1].span().unwrap();
        assert_eq!((second.line, second.column), (2, 3));
        assert_eq!(&source[second.start..second.end], "é");
        assert!(errors[0].to_string().starts_with("Erro léxico:"));
        assert!(errors[0].educational_message().contains("Dica:"));
    }

    #[test]
    fn all_pipeline_stages_use_character_columns_after_accents() {
        for (source, stage, column) in [
            ("print(\"á\",)", "Sintaxe", 10),
            ("print(\"á\"); print(x)", "Semântico", 19),
            ("print(\"á\"); print(1 / 0)", "Semântico", 23),
            ("print(\"á\"); var z = 0; print(1 / z)", "Execução", 30),
        ] {
            let result = process_source(source);
            assert!(!result.success);
            let error = &result.errors[0];
            assert_eq!(error.stage(), stage);
            let span = error.span().unwrap();
            assert_eq!((span.line, span.column), (1, column), "{source}");
            assert!(error.educational_message().contains("Dica:"));
        }
    }

    #[test]
    fn missing_tokens_have_locations_at_the_actual_end_of_source() {
        for source in ["var", "var x =", "print(\"ação\"", "if true {\n  print(\"é\")\n  "] {
            let result = process_source(source);
            assert!(!result.success, "{source}");
            for error in result.errors {
                let span = error.span().unwrap();
                assert_eq!((span.start, span.end), (source.len(), source.len()));
                assert_eq!(span.line, source.lines().count().max(1));
                assert_eq!(span.column, source.rsplit('\n').next().unwrap().chars().count() + 1);
                assert!(error.to_string().contains("código"));
            }
        }
    }

    #[test]
    fn parse_only_reports_lexical_diagnostics() {
        let errors = parse_only("@").unwrap_err();
        assert!(matches!(&errors[0], CompileError::LexerError { .. }));
        assert_eq!(errors[0].span().unwrap().column, 1);
    }

    #[test]
    fn expectations_suggestions_and_runtime_types_are_in_portuguese() {
        let result = process_source("print()");
        if let CompileError::ParserError { expected, .. } = &result.errors[0] {
            assert_eq!(expected, &["número", "texto", "identificador", "'('"]);
        } else {
            panic!("Esperado um erro de sintaxe");
        }
        let result = process_source("var nome = 1\nprint(nme)");
        if let CompileError::SemanticError { suggestion, .. } = &result.errors[0] {
            assert_eq!(suggestion.as_deref(), Some("Você quis dizer 'nome'?"));
        } else {
            panic!("Esperado um erro semântico");
        }
        let result = process_source("print(1 - true)");
        assert!(result.errors[0].to_string().contains("aos tipos inteiro e booleano"));
    }

    #[test]
    fn trace_keeps_shadowed_variables_in_each_scope_after_declaration() {
        let result = process_source("var x = 1\n{ var x = 2\n{ var x = 3\nprint(x) }\nprint(x) }\nprint(x)");
        assert!(result.success, "{:?}", result.errors);
        let step = result.execution_trace.iter().find(|step| {
            step.action == "var_decl" && step.scope_depth == 2
        }).unwrap();
        assert_eq!(step.scopes.len(), 3);
        for (i, scope) in step.scopes.iter().enumerate() {
            assert_eq!(scope.depth, i);
            assert_eq!(scope.variables.get("x"), Some(&Value::Int(i as i64 + 1)));
        }
        assert_eq!(step.variables.get("x"), Some(&Value::Int(3)));
        let final_step = result.execution_trace.last().unwrap();
        assert_eq!(final_step.scopes.len(), 1);
        assert_eq!(final_step.scopes[0].variables.get("x"), Some(&Value::Int(1)));
        assert_eq!(result.output, "3\n2\n1\n");
    }

    #[test]
    fn recursive_calls_preserve_equal_parameter_names() {
        let source = "fn rec(n) {\nif n > 0 { return rec(n - 1) }\nprint(n)\nreturn n\n}\nvar n = 99\nrec(2)";
        let result = process_source(source);
        assert!(result.success, "{:?}", result.errors);
        let step = result.execution_trace.iter().find(|step| step.output.is_some()).unwrap();
        let values: Vec<_> = step.scopes.iter().filter_map(|scope| scope.variables.get("n")).collect();
        assert_eq!(values, vec![&Value::Int(99), &Value::Int(2), &Value::Int(1), &Value::Int(0)]);
        assert_eq!(step.scopes.iter().filter(|scope| scope.is_function_scope).count(), 3);
    }
}
