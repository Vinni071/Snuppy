//! # Luminthor Engine — Lexer Module
//!
//! Tokenizes source code into a stream of typed tokens using the `logos` crate.
//! Each token carries span information (line, column) for error reporting and
//! didactic visualization in the Flutter UI.

use logos::Logos;
use serde::{Deserialize, Serialize};

/// All token types recognized by the Lumi language lexer.
#[derive(Logos, Debug, Clone, PartialEq)]
#[logos(skip r"[ \t]+")]
pub enum Token {
    // ── Keywords ──────────────────────────────────────────────
    #[token("var")]
    Var,
    #[token("const")]
    Const,
    #[token("if")]
    If,
    #[token("else")]
    Else,
    #[token("while")]
    While,
    #[token("for")]
    For,
    #[token("fn")]
    Fn,
    #[token("return")]
    Return,
    #[token("print")]
    Print,
    #[token("true")]
    True,
    #[token("false")]
    False,
    #[token("null")]
    Null,
    #[token("and")]
    And,
    #[token("or")]
    Or,
    #[token("not")]
    Not,
    #[token("in")]
    In,
    #[token("break")]
    Break,
    #[token("continue")]
    Continue,

    // ── Operators ─────────────────────────────────────────────
    #[token("+")]
    Plus,
    #[token("-")]
    Minus,
    #[token("*")]
    Star,
    #[token("/")]
    Slash,
    #[token("%")]
    Percent,
    #[token("=")]
    Assign,
    #[token("==")]
    Equal,
    #[token("!=")]
    NotEqual,
    #[token("<")]
    Less,
    #[token(">")]
    Greater,
    #[token("<=")]
    LessEqual,
    #[token(">=")]
    GreaterEqual,
    #[token("+=")]
    PlusAssign,
    #[token("-=")]
    MinusAssign,
    #[token("*=")]
    StarAssign,
    #[token("/=")]
    SlashAssign,

    // ── Delimiters ────────────────────────────────────────────
    #[token("(")]
    LParen,
    #[token(")")]
    RParen,
    #[token("{")]
    LBrace,
    #[token("}")]
    RBrace,
    #[token("[")]
    LBracket,
    #[token("]")]
    RBracket,
    #[token(",")]
    Comma,
    #[token(";")]
    Semicolon,
    #[token(":")]
    Colon,
    #[token(".")]
    Dot,

    // ── Literals ──────────────────────────────────────────────
    #[regex(r"[0-9]+\.[0-9]+", |lex| lex.slice().parse::<f64>().ok())]
    Float(f64),

    #[regex(r"[0-9]+", |lex| lex.slice().parse::<i64>().ok(), priority = 2)]
    Integer(i64),

    #[regex(r#""([^"\\]|\\.)*""#, |lex| {
        let s = lex.slice();
        Some(s[1..s.len()-1].to_string())
    })]
    String(String),

    // ── Identifiers ───────────────────────────────────────────
    #[regex(r"[a-zA-Z_][a-zA-Z0-9_]*", |lex| lex.slice().to_string(), priority = 1)]
    Identifier(String),

    // ── Whitespace / Newline ──────────────────────────────────
    #[regex(r"\n")]
    Newline,

    // ── Comments ──────────────────────────────────────────────
    #[regex(r"//[^\n]*", allow_greedy = true)]
    LineComment,

    #[regex(r"/\*([^*]|\*[^/])*\*/")]
    BlockComment,
}

/// Serializable token type for the Flutter UI.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct TokenInfo {
    pub token_type: String,
    pub lexeme: String,
    pub line: usize,
    pub column: usize,
    pub start: usize,
    pub end: usize,
}

/// Classification of tokens for UI color-coding.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum TokenCategory {
    Keyword,
    Operator,
    Delimiter,
    Literal,
    Identifier,
    Comment,
    Whitespace,
    Unknown,
}

impl Token {
    /// Returns the category of this token for syntax highlighting.
    pub fn category(&self) -> TokenCategory {
        match self {
            Token::Var | Token::Const | Token::If | Token::Else | Token::While
            | Token::For | Token::Fn | Token::Return | Token::Print | Token::True
            | Token::False | Token::Null | Token::And | Token::Or | Token::Not
            | Token::In | Token::Break | Token::Continue => TokenCategory::Keyword,

            Token::Plus | Token::Minus | Token::Star | Token::Slash | Token::Percent
            | Token::Assign | Token::Equal | Token::NotEqual | Token::Less
            | Token::Greater | Token::LessEqual | Token::GreaterEqual
            | Token::PlusAssign | Token::MinusAssign | Token::StarAssign
            | Token::SlashAssign => TokenCategory::Operator,

            Token::LParen | Token::RParen | Token::LBrace | Token::RBrace
            | Token::LBracket | Token::RBracket | Token::Comma | Token::Semicolon
            | Token::Colon | Token::Dot => TokenCategory::Delimiter,

            Token::Integer(_) | Token::Float(_) | Token::String(_) => TokenCategory::Literal,

            Token::Identifier(_) => TokenCategory::Identifier,

            Token::LineComment | Token::BlockComment => TokenCategory::Comment,

            Token::Newline => TokenCategory::Whitespace,
        }
    }

    /// Returns a human-readable name for this token type.
    pub fn type_name(&self) -> &str {
        match self {
            Token::Var => "Keyword(var)",
            Token::Const => "Keyword(const)",
            Token::If => "Keyword(if)",
            Token::Else => "Keyword(else)",
            Token::While => "Keyword(while)",
            Token::For => "Keyword(for)",
            Token::Fn => "Keyword(fn)",
            Token::Return => "Keyword(return)",
            Token::Print => "Keyword(print)",
            Token::True => "Keyword(true)",
            Token::False => "Keyword(false)",
            Token::Null => "Keyword(null)",
            Token::And => "Keyword(and)",
            Token::Or => "Keyword(or)",
            Token::Not => "Keyword(not)",
            Token::In => "Keyword(in)",
            Token::Break => "Keyword(break)",
            Token::Continue => "Keyword(continue)",
            Token::Plus => "Operator(+)",
            Token::Minus => "Operator(-)",
            Token::Star => "Operator(*)",
            Token::Slash => "Operator(/)",
            Token::Percent => "Operator(%)",
            Token::Assign => "Operator(=)",
            Token::Equal => "Operator(==)",
            Token::NotEqual => "Operator(!=)",
            Token::Less => "Operator(<)",
            Token::Greater => "Operator(>)",
            Token::LessEqual => "Operator(<=)",
            Token::GreaterEqual => "Operator(>=)",
            Token::PlusAssign => "Operator(+=)",
            Token::MinusAssign => "Operator(-=)",
            Token::StarAssign => "Operator(*=)",
            Token::SlashAssign => "Operator(/=)",
            Token::LParen => "Delimiter(()",
            Token::RParen => "Delimiter())",
            Token::LBrace => "Delimiter({)",
            Token::RBrace => "Delimiter(})",
            Token::LBracket => "Delimiter([)",
            Token::RBracket => "Delimiter(])",
            Token::Comma => "Delimiter(,)",
            Token::Semicolon => "Delimiter(;)",
            Token::Colon => "Delimiter(:)",
            Token::Dot => "Delimiter(.)",
            Token::Integer(_) => "Literal(integer)",
            Token::Float(_) => "Literal(float)",
            Token::String(_) => "Literal(string)",
            Token::Identifier(_) => "Identifier",
            Token::Newline => "Newline",
            Token::LineComment => "Comment(line)",
            Token::BlockComment => "Comment(block)",
        }
    }
}

/// Tokenize source code into a vector of `TokenInfo` structs.
///
/// This function converts raw source into a rich, serializable token stream
/// suitable for both the parser and the Flutter UI token viewer.
pub fn tokenize(source: &str) -> (Vec<TokenInfo>, Vec<String>) {
    let mut tokens = Vec::new();
    let mut errors = Vec::new();
    let mut lexer = Token::lexer(source);

    // Pre-compute line starts for line/column calculation
    let line_starts: Vec<usize> = std::iter::once(0)
        .chain(source.match_indices('\n').map(|(i, _)| i + 1))
        .collect();

    while let Some(result) = lexer.next() {
        let span = lexer.span();
        let lexeme = lexer.slice().to_string();

        // Calculate line and column from byte offset
        let (line, column) = offset_to_line_col(&line_starts, span.start);

        match result {
            Ok(token) => {
                // Skip pure whitespace tokens (newlines) for the token list,
                // but still track them internally for line counting
                if matches!(token, Token::Newline) {
                    continue;
                }

                // Skip comments from the parsed token stream but include in UI
                let token_type = token.type_name().to_string();

                tokens.push(TokenInfo {
                    token_type,
                    lexeme,
                    line,
                    column,
                    start: span.start,
                    end: span.end,
                });
            }
            Err(_) => {
                errors.push(format!(
                    "Unexpected character '{}' at line {}, column {}",
                    lexeme, line, column
                ));
            }
        }
    }

    (tokens, errors)
}

/// Convert a byte offset into a (line, column) pair (1-indexed).
fn offset_to_line_col(line_starts: &[usize], offset: usize) -> (usize, usize) {
    let line = line_starts.partition_point(|&start| start <= offset);
    let col = offset - line_starts[line - 1] + 1;
    (line, col)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_tokens() {
        let (tokens, errors) = tokenize("var x = 10");
        assert!(errors.is_empty(), "Unexpected errors: {:?}", errors);
        assert_eq!(tokens.len(), 4);
        assert_eq!(tokens[0].token_type, "Keyword(var)");
        assert_eq!(tokens[1].lexeme, "x");
        assert_eq!(tokens[2].token_type, "Operator(=)");
        assert_eq!(tokens[3].lexeme, "10");
    }

    #[test]
    fn test_string_literal() {
        let (tokens, errors) = tokenize(r#""hello world""#);
        assert!(errors.is_empty());
        assert_eq!(tokens.len(), 1);
        assert_eq!(tokens[0].token_type, "Literal(string)");
        assert_eq!(tokens[0].lexeme, r#""hello world""#);
    }

    #[test]
    fn test_float_literal() {
        let (tokens, errors) = tokenize("3.14");
        assert!(errors.is_empty());
        assert_eq!(tokens.len(), 1);
        assert_eq!(tokens[0].token_type, "Literal(float)");
    }

    #[test]
    fn test_comparison_operators() {
        let (tokens, errors) = tokenize("x <= 10 != y >= 5");
        assert!(errors.is_empty());
        assert_eq!(tokens.len(), 7);
        assert_eq!(tokens[1].token_type, "Operator(<=)");
        assert_eq!(tokens[3].token_type, "Operator(!=)");
        assert_eq!(tokens[5].token_type, "Operator(>=)");
    }

    #[test]
    fn test_multiline_line_column() {
        let source = "var x = 1\nvar y = 2";
        let (tokens, _) = tokenize(source);
        // Second line tokens
        let y_token = tokens.iter().find(|t| t.lexeme == "y").unwrap();
        assert_eq!(y_token.line, 2);
        assert_eq!(y_token.column, 5);
    }

    #[test]
    fn test_comments_included() {
        let (tokens, errors) = tokenize("// this is a comment\nvar x = 5");
        assert!(errors.is_empty());
        // Comment is included in token stream
        assert!(tokens.iter().any(|t| t.token_type == "Comment(line)"));
    }

    #[test]
    fn test_keywords() {
        let (tokens, errors) = tokenize("if else while for fn return print true false null");
        assert!(errors.is_empty());
        assert_eq!(tokens.len(), 10);
        assert!(tokens.iter().all(|t| t.token_type.starts_with("Keyword")));
    }

    #[test]
    fn test_error_on_unknown_char() {
        let (_, errors) = tokenize("var x = @");
        assert!(!errors.is_empty());
        assert!(errors[0].contains("Unexpected character '@'"));
    }
}
