//! # Snuppy Engine — Public API
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
    let (tokens, lex_errors) = crate::lexer::tokenize(source);

    for err in &lex_errors {
        all_errors.push(CompileError::lexer(err.clone(), None));
    }

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
    let (tokens, _) = crate::lexer::tokenize(source);
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
}
