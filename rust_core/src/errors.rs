//! # Luminthor Engine — Error Types
//!
//! Rich error types for all compiler pipeline stages.
//! Errors carry span information and helpful messages for the
//! educational UI, including suggestions and context.

use crate::ast::Span;
use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Top-level error type for the Luminthor compiler engine.
#[derive(Error, Debug, Clone, Serialize, Deserialize)]
pub enum CompileError {
    #[error("Lexer error: {message}")]
    LexerError {
        message: String,
        span: Option<Span>,
    },

    #[error("Parser error: {message}")]
    ParserError {
        message: String,
        span: Option<Span>,
        expected: Vec<String>,
    },

    #[error("Semantic error: {message}")]
    SemanticError {
        message: String,
        span: Option<Span>,
        suggestion: Option<String>,
    },

    #[error("Runtime error: {message}")]
    RuntimeError {
        message: String,
        span: Option<Span>,
        call_stack: Vec<String>,
    },
}

impl CompileError {
    /// Create a lexer error.
    pub fn lexer(message: impl Into<String>, span: Option<Span>) -> Self {
        Self::LexerError {
            message: message.into(),
            span,
        }
    }

    /// Create a parser error.
    pub fn parser(
        message: impl Into<String>,
        span: Option<Span>,
        expected: Vec<String>,
    ) -> Self {
        Self::ParserError {
            message: message.into(),
            span,
            expected,
        }
    }

    /// Create a semantic error with optional suggestion.
    pub fn semantic(
        message: impl Into<String>,
        span: Option<Span>,
        suggestion: Option<String>,
    ) -> Self {
        Self::SemanticError {
            message: message.into(),
            span,
            suggestion,
        }
    }

    /// Create a runtime error.
    pub fn runtime(
        message: impl Into<String>,
        span: Option<Span>,
        call_stack: Vec<String>,
    ) -> Self {
        Self::RuntimeError {
            message: message.into(),
            span,
            call_stack,
        }
    }

    /// Get the span associated with this error, if any.
    pub fn span(&self) -> Option<&Span> {
        match self {
            Self::LexerError { span, .. } => span.as_ref(),
            Self::ParserError { span, .. } => span.as_ref(),
            Self::SemanticError { span, .. } => span.as_ref(),
            Self::RuntimeError { span, .. } => span.as_ref(),
        }
    }

    /// Get the error stage name for UI categorization.
    pub fn stage(&self) -> &str {
        match self {
            Self::LexerError { .. } => "Lexer",
            Self::ParserError { .. } => "Parser",
            Self::SemanticError { .. } => "Semantic",
            Self::RuntimeError { .. } => "Runtime",
        }
    }

    /// Get a user-friendly, educational error message.
    pub fn educational_message(&self) -> String {
        match self {
            Self::LexerError { message, .. } => {
                format!(
                    "🔤 Tokenization Error\n\
                     The lexer found a character it doesn't understand.\n\
                     {}\n\
                     💡 Tip: Check for typos or unsupported characters.",
                    message
                )
            }
            Self::ParserError { message, expected, .. } => {
                let expected_str = if expected.is_empty() {
                    String::new()
                } else {
                    format!("\n📋 Expected: {}", expected.join(", "))
                };
                format!(
                    "🌳 Parse Error\n\
                     The parser couldn't understand the structure of your code.\n\
                     {}{}\n\
                     💡 Tip: Check your syntax — missing brackets, semicolons, or keywords.",
                    message, expected_str
                )
            }
            Self::SemanticError { message, suggestion, .. } => {
                let suggestion_str = suggestion
                    .as_ref()
                    .map(|s| format!("\n💡 Suggestion: {}", s))
                    .unwrap_or_default();
                format!(
                    "🔍 Semantic Error\n\
                     Your code syntax is correct, but there's a logical issue.\n\
                     {}{}\n\
                     💡 Tip: This error is caught before running the code.",
                    message, suggestion_str
                )
            }
            Self::RuntimeError { message, call_stack, .. } => {
                let stack_str = if call_stack.is_empty() {
                    String::new()
                } else {
                    format!(
                        "\n📚 Call Stack:\n{}",
                        call_stack
                            .iter()
                            .enumerate()
                            .map(|(i, s)| format!("  {}. {}", i + 1, s))
                            .collect::<Vec<_>>()
                            .join("\n")
                    )
                };
                format!(
                    "⚡ Runtime Error\n\
                     An error occurred while executing your program.\n\
                     {}{}\n\
                     💡 Tip: Use the debugger to step through your code.",
                    message, stack_str
                )
            }
        }
    }
}
