//! # Luminthor Engine — Parser Module
//!
//! Parses a stream of tokens into a typed AST using hand-written recursive
//! descent parsing. This provides better error messages and more control
//! than a combinator-based approach for our educational use case.
//!
//! Grammar (simplified EBNF):
//! ```text
//! program     → statement* EOF
//! statement   → var_decl | assignment | if_stmt | while_stmt | for_stmt
//!             | fn_decl | return_stmt | print_stmt | break_stmt
//!             | continue_stmt | block | expr_stmt
//! var_decl    → ("var" | "const") IDENT "=" expression
//! assignment  → IDENT ("=" | "+=" | "-=" | "*=" | "/=") expression
//! if_stmt     → "if" expression "{" statement* "}" ("else" "{" statement* "}")?
//! while_stmt  → "while" expression "{" statement* "}"
//! for_stmt    → "for" IDENT "in" expression "{" statement* "}"
//! fn_decl     → "fn" IDENT "(" params? ")" "{" statement* "}"
//! return_stmt → "return" expression?
//! print_stmt  → "print" "(" expression ")"
//! block       → "{" statement* "}"
//! expr_stmt   → expression
//!
//! expression  → or_expr
//! or_expr     → and_expr ("or" and_expr)*
//! and_expr    → equality ("and" equality)*
//! equality    → comparison (("==" | "!=") comparison)*
//! comparison  → addition (("<" | ">" | "<=" | ">=") addition)*
//! addition    → multiply (("+" | "-") multiply)*
//! multiply    → unary (("*" | "/" | "%") unary)*
//! unary       → ("-" | "not") unary | call
//! call        → primary ("(" arguments? ")")*
//! primary     → INT | FLOAT | STRING | "true" | "false" | "null"
//!             | IDENT | "(" expression ")"
//! ```

use crate::ast::*;
use crate::errors::CompileError;
use crate::lexer::TokenInfo;

/// Parser state holding the token stream and current position.
pub struct Parser {
    tokens: Vec<TokenInfo>,
    pos: usize,
    errors: Vec<CompileError>,
    _source: String,
}

impl Parser {
    /// Create a new parser from a token stream.
    pub fn new(tokens: Vec<TokenInfo>, source: String) -> Self {
        // Filter out comments for parsing
        let tokens: Vec<TokenInfo> = tokens
            .into_iter()
            .filter(|t| !t.token_type.starts_with("Comment"))
            .collect();

        Self {
            tokens,
            pos: 0,
            errors: Vec::new(),
            _source: source,
        }
    }

    /// Parse the entire program.
    pub fn parse_program(&mut self) -> Result<Program, Vec<CompileError>> {
        let mut statements = Vec::new();

        while !self.is_at_end() {
            if self.check_type("Delimiter(;)") {
                self.advance();
                continue;
            }
            match self.parse_statement() {
                Ok(stmt) => statements.push(stmt),
                Err(e) => {
                    self.errors.push(e);
                    self.synchronize();
                }
            }
        }

        if self.errors.is_empty() {
            Ok(Program { statements })
        } else {
            Err(self.errors.clone())
        }
    }

    // ── Statement Parsing ────────────────────────────────────

    fn parse_statement(&mut self) -> Result<Stmt, CompileError> {
        let token = self.peek().ok_or_else(|| {
            CompileError::parser("Unexpected end of input", None, vec![])
        })?;

        match token.token_type.as_str() {
            "Keyword(var)" => self.parse_var_decl(true),
            "Keyword(const)" => self.parse_var_decl(false),
            "Keyword(if)" => self.parse_if_stmt(),
            "Keyword(while)" => self.parse_while_stmt(),
            "Keyword(for)" => self.parse_for_stmt(),
            "Keyword(fn)" => self.parse_fn_decl(),
            "Keyword(return)" => self.parse_return_stmt(),
            "Keyword(print)" => self.parse_print_stmt(),
            "Keyword(break)" => self.parse_break_stmt(),
            "Keyword(continue)" => self.parse_continue_stmt(),
            "Delimiter({)" => self.parse_block(),
            _ => self.parse_assignment_or_expr(),
        }
    }

    fn parse_var_decl(&mut self, mutable: bool) -> Result<Stmt, CompileError> {
        let start_token = self.advance().unwrap(); // consume 'var' or 'const'
        let span_start = start_token.start;
        let line = start_token.line;
        let col = start_token.column;

        let name_token = self.expect_identifier()?;
        let name = name_token.lexeme.clone();

        let initializer = if self.check_type("Operator(=)") {
            self.advance(); // consume '='
            Some(self.parse_expression()?)
        } else {
            None
        };

        let span_end = self.prev_end();

        Ok(Stmt {
            kind: StmtKind::VarDecl {
                name,
                initializer,
                mutable,
            },
            span: Span::new(span_start, span_end, line, col),
        })
    }

    fn parse_if_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume 'if'
        let condition = self.parse_expression()?;

        self.expect_type("Delimiter({)", "'{'")?;
        let then_branch = self.parse_block_body()?;
        self.expect_type("Delimiter(})", "'}'")?;

        let else_branch = if self.check_type("Keyword(else)") {
            self.advance(); // consume 'else'
            if self.check_type("Keyword(if)") {
                // else if — wrap in a single-statement block
                let else_if = self.parse_if_stmt()?;
                Some(vec![else_if])
            } else {
                self.expect_type("Delimiter({)", "'{'")?;
                let stmts = self.parse_block_body()?;
                self.expect_type("Delimiter(})", "'}'")?;
                Some(stmts)
            }
        } else {
            None
        };

        Ok(Stmt {
            kind: StmtKind::If {
                condition,
                then_branch,
                else_branch,
            },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_while_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume 'while'
        let condition = self.parse_expression()?;

        self.expect_type("Delimiter({)", "'{'")?;
        let body = self.parse_block_body()?;
        self.expect_type("Delimiter(})", "'}'")?;

        Ok(Stmt {
            kind: StmtKind::While { condition, body },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_for_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume 'for'
        let var_token = self.expect_identifier()?;
        let variable = var_token.lexeme.clone();

        self.expect_type("Keyword(in)", "'in'")?;
        let iterable = self.parse_expression()?;

        self.expect_type("Delimiter({)", "'{'")?;
        let body = self.parse_block_body()?;
        self.expect_type("Delimiter(})", "'}'")?;

        Ok(Stmt {
            kind: StmtKind::For {
                variable,
                iterable,
                body,
            },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_fn_decl(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume 'fn'
        let name_token = self.expect_identifier()?;
        let name = name_token.lexeme.clone();

        self.expect_type("Delimiter(()", "'('")?;

        let mut params = Vec::new();
        if !self.check_type("Delimiter())") {
            let first = self.expect_identifier()?;
            params.push(first.lexeme.clone());
            while self.check_type("Delimiter(,)") {
                self.advance(); // consume ','
                let param = self.expect_identifier()?;
                params.push(param.lexeme.clone());
            }
        }

        self.expect_type("Delimiter())", "')'")?;
        self.expect_type("Delimiter({)", "'{'")?;
        let body = self.parse_block_body()?;
        self.expect_type("Delimiter(})", "'}'")?;

        Ok(Stmt {
            kind: StmtKind::FnDecl { name, params, body },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_return_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume 'return'

        let value = if !self.is_at_end()
            && !self.check_type("Delimiter(})")
            && !self.check_type("Delimiter(;)")
        {
            Some(self.parse_expression()?)
        } else {
            None
        };

        Ok(Stmt {
            kind: StmtKind::Return { value },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_print_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume 'print'
        self.expect_type("Delimiter(()", "'('")?;
        let value = self.parse_expression()?;
        self.expect_type("Delimiter())", "')'")?;

        Ok(Stmt {
            kind: StmtKind::Print { value },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_break_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap();
        Ok(Stmt {
            kind: StmtKind::Break,
            span: Span::new(start.start, start.end, start.line, start.column),
        })
    }

    fn parse_continue_stmt(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap();
        Ok(Stmt {
            kind: StmtKind::Continue,
            span: Span::new(start.start, start.end, start.line, start.column),
        })
    }

    fn parse_block(&mut self) -> Result<Stmt, CompileError> {
        let start = self.advance().unwrap(); // consume '{'
        let statements = self.parse_block_body()?;
        self.expect_type("Delimiter(})", "'}'")?;

        Ok(Stmt {
            kind: StmtKind::Block { statements },
            span: Span::new(start.start, self.prev_end(), start.line, start.column),
        })
    }

    fn parse_block_body(&mut self) -> Result<Vec<Stmt>, CompileError> {
        let mut stmts = Vec::new();
        while !self.check_type("Delimiter(})") && !self.is_at_end() {
            if self.check_type("Delimiter(;)") {
                self.advance();
                continue;
            }
            match self.parse_statement() {
                Ok(stmt) => stmts.push(stmt),
                Err(e) => {
                    self.errors.push(e);
                    self.synchronize();
                }
            }
        }
        Ok(stmts)
    }

    fn parse_assignment_or_expr(&mut self) -> Result<Stmt, CompileError> {
        let expr = self.parse_expression()?;

        // Check if this is an assignment
        if let ExprKind::Identifier(ref name) = expr.kind {
            if self.check_assign_op() {
                let op_token = self.advance().unwrap();
                let value_expr = self.parse_expression()?;

                let final_value = match op_token.token_type.as_str() {
                    "Operator(=)" => value_expr,
                    "Operator(+=)" => Expr {
                        span: value_expr.span.clone(),
                        kind: ExprKind::BinaryOp {
                            left: Box::new(expr.clone()),
                            op: BinaryOperator::Add,
                            right: Box::new(value_expr),
                        },
                    },
                    "Operator(-=)" => Expr {
                        span: value_expr.span.clone(),
                        kind: ExprKind::BinaryOp {
                            left: Box::new(expr.clone()),
                            op: BinaryOperator::Subtract,
                            right: Box::new(value_expr),
                        },
                    },
                    "Operator(*=)" => Expr {
                        span: value_expr.span.clone(),
                        kind: ExprKind::BinaryOp {
                            left: Box::new(expr.clone()),
                            op: BinaryOperator::Multiply,
                            right: Box::new(value_expr),
                        },
                    },
                    "Operator(/=)" => Expr {
                        span: value_expr.span.clone(),
                        kind: ExprKind::BinaryOp {
                            left: Box::new(expr.clone()),
                            op: BinaryOperator::Divide,
                            right: Box::new(value_expr),
                        },
                    },
                    _ => value_expr,
                };

                return Ok(Stmt {
                    span: expr.span.clone(),
                    kind: StmtKind::Assignment {
                        target: name.clone(),
                        value: final_value,
                    },
                });
            }
        }

        // Optional semicolons
        if self.check_type("Delimiter(;)") {
            self.advance();
        }

        Ok(Stmt {
            span: expr.span.clone(),
            kind: StmtKind::ExprStmt { expr },
        })
    }

    // ── Expression Parsing (Pratt-style precedence climbing) ──

    fn parse_expression(&mut self) -> Result<Expr, CompileError> {
        self.parse_or()
    }

    fn parse_or(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_and()?;

        while self.check_type("Keyword(or)") {
            self.advance();
            let right = self.parse_and()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op: BinaryOperator::Or,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }

    fn parse_and(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_equality()?;

        while self.check_type("Keyword(and)") {
            self.advance();
            let right = self.parse_equality()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op: BinaryOperator::And,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }

    fn parse_equality(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_comparison()?;

        while self.check_type("Operator(==)") || self.check_type("Operator(!=)") {
            let op_token = self.advance().unwrap();
            let op = match op_token.token_type.as_str() {
                "Operator(==)" => BinaryOperator::Equal,
                "Operator(!=)" => BinaryOperator::NotEqual,
                _ => unreachable!(),
            };
            let right = self.parse_comparison()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }

    fn parse_comparison(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_addition()?;

        while self.check_type("Operator(<)")
            || self.check_type("Operator(>)")
            || self.check_type("Operator(<=)")
            || self.check_type("Operator(>=)")
        {
            let op_token = self.advance().unwrap();
            let op = match op_token.token_type.as_str() {
                "Operator(<)" => BinaryOperator::Less,
                "Operator(>)" => BinaryOperator::Greater,
                "Operator(<=)" => BinaryOperator::LessEqual,
                "Operator(>=)" => BinaryOperator::GreaterEqual,
                _ => unreachable!(),
            };
            let right = self.parse_addition()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }

    fn parse_addition(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_multiplication()?;

        while self.check_type("Operator(+)") || self.check_type("Operator(-)") {
            let op_token = self.advance().unwrap();
            let op = match op_token.token_type.as_str() {
                "Operator(+)" => BinaryOperator::Add,
                "Operator(-)" => BinaryOperator::Subtract,
                _ => unreachable!(),
            };
            let right = self.parse_multiplication()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }

    fn parse_multiplication(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_unary()?;

        while self.check_type("Operator(*)")
            || self.check_type("Operator(/)")
            || self.check_type("Operator(%)")
        {
            let op_token = self.advance().unwrap();
            let op = match op_token.token_type.as_str() {
                "Operator(*)" => BinaryOperator::Multiply,
                "Operator(/)" => BinaryOperator::Divide,
                "Operator(%)" => BinaryOperator::Modulo,
                _ => unreachable!(),
            };
            let right = self.parse_unary()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }

    fn parse_unary(&mut self) -> Result<Expr, CompileError> {
        if self.check_type("Operator(-)") {
            let start = self.advance().unwrap();
            let operand = self.parse_unary()?;
            return Ok(Expr {
                span: Span::new(start.start, operand.span.end, start.line, start.column),
                kind: ExprKind::UnaryOp {
                    op: UnaryOperator::Negate,
                    operand: Box::new(operand),
                },
            });
        }

        if self.check_type("Keyword(not)") {
            let start = self.advance().unwrap();
            let operand = self.parse_unary()?;
            return Ok(Expr {
                span: Span::new(start.start, operand.span.end, start.line, start.column),
                kind: ExprKind::UnaryOp {
                    op: UnaryOperator::Not,
                    operand: Box::new(operand),
                },
            });
        }

        self.parse_call()
    }

    fn parse_call(&mut self) -> Result<Expr, CompileError> {
        let mut expr = self.parse_primary()?;

        // Handle function calls: ident(args...)
        while self.check_type("Delimiter(()") {
            if let ExprKind::Identifier(ref name) = expr.kind {
                let callee = name.clone();
                self.advance(); // consume '('

                let mut args = Vec::new();
                if !self.check_type("Delimiter())") {
                    args.push(self.parse_expression()?);
                    while self.check_type("Delimiter(,)") {
                        self.advance();
                        args.push(self.parse_expression()?);
                    }
                }

                let end_token = self.expect_type("Delimiter())", "')'")?;

                expr = Expr {
                    span: Span::new(
                        expr.span.start,
                        end_token.end,
                        expr.span.line,
                        expr.span.column,
                    ),
                    kind: ExprKind::Call { callee, args },
                };
            } else {
                break;
            }
        }

        Ok(expr)
    }

    fn parse_primary(&mut self) -> Result<Expr, CompileError> {
        let token = self.advance().ok_or_else(|| {
            CompileError::parser(
                "Unexpected end of input, expected an expression",
                None,
                vec!["number".into(), "string".into(), "identifier".into()],
            )
        })?;

        match token.token_type.as_str() {
            "Literal(integer)" => {
                let val: i64 = token.lexeme.parse().map_err(|_| {
                    CompileError::parser(
                        format!("Invalid integer: {}", token.lexeme),
                        Some(Span::new(token.start, token.end, token.line, token.column)),
                        vec![],
                    )
                })?;
                Ok(Expr {
                    span: Span::new(token.start, token.end, token.line, token.column),
                    kind: ExprKind::IntLiteral(val),
                })
            }
            "Literal(float)" => {
                let val: f64 = token.lexeme.parse().map_err(|_| {
                    CompileError::parser(
                        format!("Invalid float: {}", token.lexeme),
                        Some(Span::new(token.start, token.end, token.line, token.column)),
                        vec![],
                    )
                })?;
                Ok(Expr {
                    span: Span::new(token.start, token.end, token.line, token.column),
                    kind: ExprKind::FloatLiteral(val),
                })
            }
            "Literal(string)" => {
                // Remove surrounding quotes from lexeme
                let val = if token.lexeme.starts_with('"') && token.lexeme.ends_with('"') {
                    token.lexeme[1..token.lexeme.len() - 1].to_string()
                } else {
                    token.lexeme.clone()
                };
                Ok(Expr {
                    span: Span::new(token.start, token.end, token.line, token.column),
                    kind: ExprKind::StringLiteral(val),
                })
            }
            "Keyword(true)" => Ok(Expr {
                span: Span::new(token.start, token.end, token.line, token.column),
                kind: ExprKind::BoolLiteral(true),
            }),
            "Keyword(false)" => Ok(Expr {
                span: Span::new(token.start, token.end, token.line, token.column),
                kind: ExprKind::BoolLiteral(false),
            }),
            "Keyword(null)" => Ok(Expr {
                span: Span::new(token.start, token.end, token.line, token.column),
                kind: ExprKind::NullLiteral,
            }),
            "Identifier" => Ok(Expr {
                span: Span::new(token.start, token.end, token.line, token.column),
                kind: ExprKind::Identifier(token.lexeme.clone()),
            }),
            "Delimiter(()" => {
                let inner = self.parse_expression()?;
                self.expect_type("Delimiter())", "')'")?;
                Ok(Expr {
                    span: Span::new(
                        token.start,
                        self.prev_end(),
                        token.line,
                        token.column,
                    ),
                    kind: ExprKind::Group(Box::new(inner)),
                })
            }
            _ => Err(CompileError::parser(
                format!("Unexpected token: '{}'", token.lexeme),
                Some(Span::new(token.start, token.end, token.line, token.column)),
                vec![
                    "number".into(),
                    "string".into(),
                    "identifier".into(),
                    "'('".into(),
                ],
            )),
        }
    }

    // ── Helper Methods ───────────────────────────────────────

    /// Peek at the current token without consuming it.
    fn peek(&self) -> Option<&TokenInfo> {
        self.tokens.get(self.pos)
    }

    /// Advance to the next token and return the consumed token.
    fn advance(&mut self) -> Option<TokenInfo> {
        if self.is_at_end() {
            None
        } else {
            let token = self.tokens[self.pos].clone();
            self.pos += 1;
            Some(token)
        }
    }

    /// Check if the current token matches the given type.
    fn check_type(&self, token_type: &str) -> bool {
        self.peek()
            .map(|t| t.token_type == token_type)
            .unwrap_or(false)
    }

    /// Check if the current token is an assignment operator.
    fn check_assign_op(&self) -> bool {
        self.peek()
            .map(|t| {
                matches!(
                    t.token_type.as_str(),
                    "Operator(=)" | "Operator(+=)" | "Operator(-=)"
                        | "Operator(*=)" | "Operator(/=)"
                )
            })
            .unwrap_or(false)
    }

    /// Expect a token of a specific type, returning an error if not found.
    fn expect_type(&mut self, token_type: &str, description: &str) -> Result<TokenInfo, CompileError> {
        if self.check_type(token_type) {
            Ok(self.advance().unwrap())
        } else {
            let span = self.peek().map(|t| {
                Span::new(t.start, t.end, t.line, t.column)
            });
            let found = self.peek()
                .map(|t| format!("'{}'", t.lexeme))
                .unwrap_or_else(|| "end of input".to_string());

            Err(CompileError::parser(
                format!("Expected {} but found {}", description, found),
                span,
                vec![description.to_string()],
            ))
        }
    }

    /// Expect an identifier token.
    fn expect_identifier(&mut self) -> Result<TokenInfo, CompileError> {
        if self.check_type("Identifier") {
            Ok(self.advance().unwrap())
        } else {
            let span = self.peek().map(|t| Span::new(t.start, t.end, t.line, t.column));
            let found = self.peek()
                .map(|t| format!("'{}'", t.lexeme))
                .unwrap_or_else(|| "end of input".to_string());

            Err(CompileError::parser(
                format!("Expected identifier but found {}", found),
                span,
                vec!["identifier".to_string()],
            ))
        }
    }

    /// Check if we've consumed all tokens.
    fn is_at_end(&self) -> bool {
        self.pos >= self.tokens.len()
    }

    /// Get the end position of the previous token.
    fn prev_end(&self) -> usize {
        if self.pos > 0 {
            self.tokens[self.pos - 1].end
        } else {
            0
        }
    }

    /// Synchronize after an error by skipping to the next statement boundary.
    fn synchronize(&mut self) {
        while !self.is_at_end() {
            let token = self.peek().unwrap();
            match token.token_type.as_str() {
                "Keyword(var)" | "Keyword(const)" | "Keyword(if)" | "Keyword(while)"
                | "Keyword(for)" | "Keyword(fn)" | "Keyword(return)" | "Keyword(print)"
                | "Keyword(break)" | "Keyword(continue)" => return,
                "Delimiter(})" => return,
                _ => {
                    self.advance();
                }
            }
        }
    }
}

/// Convenience function to parse source code into an AST.
pub fn parse(tokens: Vec<TokenInfo>, source: &str) -> Result<Program, Vec<CompileError>> {
    let mut parser = Parser::new(tokens, source.to_string());
    parser.parse_program()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lexer::tokenize;

    fn parse_source(source: &str) -> Result<Program, Vec<CompileError>> {
        let (tokens, _) = tokenize(source);
        parse(tokens, source)
    }

    #[test]
    fn test_var_decl() {
        let program = parse_source("var x = 10").unwrap();
        assert_eq!(program.statements.len(), 1);
        match &program.statements[0].kind {
            StmtKind::VarDecl { name, mutable, .. } => {
                assert_eq!(name, "x");
                assert!(*mutable);
            }
            _ => panic!("Expected VarDecl"),
        }
    }

    #[test]
    fn test_const_decl() {
        let program = parse_source("const pi = 3.14").unwrap();
        match &program.statements[0].kind {
            StmtKind::VarDecl { name, mutable, .. } => {
                assert_eq!(name, "pi");
                assert!(!*mutable);
            }
            _ => panic!("Expected VarDecl (const)"),
        }
    }

    #[test]
    fn test_binary_expression() {
        let program = parse_source("var x = 1 + 2 * 3").unwrap();
        match &program.statements[0].kind {
            StmtKind::VarDecl { initializer: Some(expr), .. } => {
                // Should be 1 + (2 * 3) due to precedence
                match &expr.kind {
                    ExprKind::BinaryOp { op, .. } => {
                        assert_eq!(*op, BinaryOperator::Add);
                    }
                    _ => panic!("Expected BinaryOp"),
                }
            }
            _ => panic!("Expected VarDecl with initializer"),
        }
    }

    #[test]
    fn test_if_statement() {
        let source = r#"if x < 10 {
            print("small")
        }"#;
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::If { then_branch, else_branch, .. } => {
                assert!(!then_branch.is_empty());
                assert!(else_branch.is_none());
            }
            _ => panic!("Expected If"),
        }
    }

    #[test]
    fn test_if_else() {
        let source = r#"if x < 10 {
            print("small")
        } else {
            print("big")
        }"#;
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::If { else_branch, .. } => {
                assert!(else_branch.is_some());
            }
            _ => panic!("Expected If with else"),
        }
    }

    #[test]
    fn test_while_loop() {
        let source = "while x < 10 { x = x + 1 }";
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::While { body, .. } => {
                assert_eq!(body.len(), 1);
            }
            _ => panic!("Expected While"),
        }
    }

    #[test]
    fn test_function_declaration() {
        let source = "fn add(a, b) { return a + b }";
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::FnDecl { name, params, body } => {
                assert_eq!(name, "add");
                assert_eq!(params, &["a", "b"]);
                assert_eq!(body.len(), 1);
            }
            _ => panic!("Expected FnDecl"),
        }
    }

    #[test]
    fn test_function_call() {
        let source = "var result = add(1, 2)";
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::VarDecl { initializer: Some(expr), .. } => {
                match &expr.kind {
                    ExprKind::Call { callee, args } => {
                        assert_eq!(callee, "add");
                        assert_eq!(args.len(), 2);
                    }
                    _ => panic!("Expected Call"),
                }
            }
            _ => panic!("Expected VarDecl"),
        }
    }

    #[test]
    fn test_print_statement() {
        let source = r#"print("hello")"#;
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::Print { .. } => {}
            _ => panic!("Expected Print"),
        }
    }

    #[test]
    fn test_assignment() {
        let source = "x = 42";
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::Assignment { target, .. } => {
                assert_eq!(target, "x");
            }
            _ => panic!("Expected Assignment"),
        }
    }

    #[test]
    fn test_compound_assignment() {
        let source = "x += 5";
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::Assignment { target, value } => {
                assert_eq!(target, "x");
                match &value.kind {
                    ExprKind::BinaryOp { op, .. } => {
                        assert_eq!(*op, BinaryOperator::Add);
                    }
                    _ => panic!("Expected desugared BinaryOp"),
                }
            }
            _ => panic!("Expected Assignment"),
        }
    }

    #[test]
    fn test_nested_expressions() {
        let source = "var x = (1 + 2) * 3";
        let program = parse_source(source).unwrap();
        match &program.statements[0].kind {
            StmtKind::VarDecl { initializer: Some(expr), .. } => {
                match &expr.kind {
                    ExprKind::BinaryOp { op, left, .. } => {
                        assert_eq!(*op, BinaryOperator::Multiply);
                        match &left.kind {
                            ExprKind::Group(_) => {}
                            _ => panic!("Expected Group on left"),
                        }
                    }
                    _ => panic!("Expected BinaryOp"),
                }
            }
            _ => panic!("Expected VarDecl"),
        }
    }

    #[test]
    fn test_multiline_program() {
        let source = r#"
var x = 10
var y = 20
var sum = x + y
print(sum)
"#;
        let program = parse_source(source).unwrap();
        assert_eq!(program.statements.len(), 4);
    }

    #[test]
    fn test_error_recovery() {
        let source = "var = 10\nvar y = 20";
        let result = parse_source(source);
        // Should produce errors but potentially recover
        assert!(result.is_err());
    }

    #[test]
    fn test_optional_semicolons() {
        let source = "var x = 10; var y = 20;;; print(x);";
        let program = parse_source(source).unwrap();
        assert_eq!(program.statements.len(), 3);
    }
}
