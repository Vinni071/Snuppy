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
    #[error("Erro léxico: {message}")]
    LexerError {
        message: String,
        span: Option<Span>,
    },

    #[error("Erro de sintaxe: {message}")]
    ParserError {
        message: String,
        span: Option<Span>,
        expected: Vec<String>,
    },

    #[error("Erro semântico: {message}")]
    SemanticError {
        message: String,
        span: Option<Span>,
        suggestion: Option<String>,
    },

    #[error("Erro de execução: {message}")]
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
            Self::LexerError { .. } => "Léxico",
            Self::ParserError { .. } => "Sintaxe",
            Self::SemanticError { .. } => "Semântico",
            Self::RuntimeError { .. } => "Execução",
        }
    }

    /// Get a user-friendly, educational error message.
    pub fn educational_message(&self) -> String {
        match self {
            Self::LexerError { message, .. } => {
                format!(
                    "🔤 Erro de análise léxica\n\
                     O analisador léxico encontrou um caractere ou literal inválido.\n\
                     {}\n\
                     💡 Dica: confira se há erros de digitação, caracteres não aceitos ou literais inválidos.",
                    message
                )
            }
            Self::ParserError { message, expected, .. } => {
                let expected_str = if expected.is_empty() {
                    String::new()
                } else {
                    format!("\n📋 Esperado: {}", expected.join(", "))
                };
                format!(
                    "🌳 Erro de sintaxe\n\
                     O analisador sintático não conseguiu entender a estrutura do seu código.\n\
                     {}{}\n\
                     💡 Dica: confira a sintaxe — podem faltar parênteses, chaves, ponto e vírgula ou palavras-chave.",
                    message, expected_str
                )
            }
            Self::SemanticError { message, suggestion, .. } => {
                let suggestion_str = suggestion
                    .as_ref()
                    .map(|s| format!("\n💡 Sugestão: {}", s))
                    .unwrap_or_default();
                format!(
                    "🔍 Erro semântico\n\
                     A sintaxe do seu código está correta, mas há um problema de significado.\n\
                     {}{}\n\
                     💡 Dica: este erro é identificado antes de executar o código.",
                    message, suggestion_str
                )
            }
            Self::RuntimeError { message, call_stack, .. } => {
                let stack_str = if call_stack.is_empty() {
                    String::new()
                } else {
                    format!(
                        "\n📚 Pilha de chamadas:\n{}",
                        call_stack
                            .iter()
                            .enumerate()
                            .map(|(i, s)| format!("  {}. {}", i + 1, s))
                            .collect::<Vec<_>>()
                            .join("\n")
                    )
                };
                format!(
                    "⚡ Erro de execução\n\
                     Ocorreu um erro durante a execução do seu programa.\n\
                     {}{}\n\
                     💡 Dica: use o depurador para acompanhar seu código passo a passo.",
                    message, stack_str
                )
            }
        }
    }
}
