//! # Snuppy Engine — AST Module
//!
//! Typed Abstract Syntax Tree structures representing the Lumi language.
//! All nodes carry span information for source-level mapping and are
//! fully serializable for transmission to the Flutter UI.

use serde::{Deserialize, Serialize};

/// Span information for source mapping.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Span {
    pub start: usize,
    pub end: usize,
    pub line: usize,
    pub column: usize,
}

impl Span {
    pub fn new(start: usize, end: usize, line: usize, column: usize) -> Self {
        Self { start, end, line, column }
    }

    pub fn dummy() -> Self {
        Self { start: 0, end: 0, line: 0, column: 0 }
    }
}

/// A complete program — the root AST node.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Program {
    pub statements: Vec<Stmt>,
}

/// Statements — actions that produce side effects.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Stmt {
    pub kind: StmtKind,
    pub span: Span,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum StmtKind {
    /// `var x = expr` or `var x`
    VarDecl {
        name: String,
        initializer: Option<Expr>,
        mutable: bool,
    },
    /// `x = expr` or `x += expr`
    Assignment {
        target: String,
        value: Expr,
    },
    /// `if cond { ... } else { ... }`
    If {
        condition: Expr,
        then_branch: Vec<Stmt>,
        else_branch: Option<Vec<Stmt>>,
    },
    /// `while cond { ... }`
    While {
        condition: Expr,
        body: Vec<Stmt>,
    },
    /// `for x in range { ... }`
    For {
        variable: String,
        iterable: Expr,
        body: Vec<Stmt>,
    },
    /// `fn name(params) { ... }`
    FnDecl {
        name: String,
        params: Vec<String>,
        body: Vec<Stmt>,
    },
    /// `return expr`
    Return {
        value: Option<Expr>,
    },
    /// `print(expr)`
    Print {
        value: Expr,
    },
    /// `break`
    Break,
    /// `continue`
    Continue,
    /// `{ ... }` block
    Block {
        statements: Vec<Stmt>,
    },
    /// Expression used as statement
    ExprStmt {
        expr: Expr,
    },
}

/// Expressions — constructs that produce values.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Expr {
    pub kind: ExprKind,
    pub span: Span,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ExprKind {
    /// Integer literal: `42`
    IntLiteral(i64),
    /// Float literal: `3.14`
    FloatLiteral(f64),
    /// String literal: `"hello"`
    StringLiteral(String),
    /// Boolean literal: `true` / `false`
    BoolLiteral(bool),
    /// Null literal
    NullLiteral,
    /// Variable reference: `x`
    Identifier(String),
    /// Binary operation: `a + b`
    BinaryOp {
        left: Box<Expr>,
        op: BinaryOperator,
        right: Box<Expr>,
    },
    /// Unary operation: `-x`, `not x`
    UnaryOp {
        op: UnaryOperator,
        operand: Box<Expr>,
    },
    /// Function call: `foo(a, b)`
    Call {
        callee: String,
        args: Vec<Expr>,
    },
    /// Grouping: `(expr)`
    Group(Box<Expr>),
    /// Range expression: `0..10`
    Range {
        start: Box<Expr>,
        end: Box<Expr>,
    },
}

/// Binary operators.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum BinaryOperator {
    Add,
    Subtract,
    Multiply,
    Divide,
    Modulo,
    Equal,
    NotEqual,
    Less,
    Greater,
    LessEqual,
    GreaterEqual,
    And,
    Or,
}

impl BinaryOperator {
    pub fn symbol(&self) -> &str {
        match self {
            Self::Add => "+",
            Self::Subtract => "-",
            Self::Multiply => "*",
            Self::Divide => "/",
            Self::Modulo => "%",
            Self::Equal => "==",
            Self::NotEqual => "!=",
            Self::Less => "<",
            Self::Greater => ">",
            Self::LessEqual => "<=",
            Self::GreaterEqual => ">=",
            Self::And => "and",
            Self::Or => "or",
        }
    }
}

/// Unary operators.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum UnaryOperator {
    Negate,
    Not,
}

impl UnaryOperator {
    pub fn symbol(&self) -> &str {
        match self {
            Self::Negate => "-",
            Self::Not => "not",
        }
    }
}

// ── AST Serialization Helpers ─────────────────────────────────

/// Serializable representation of an AST node for tree visualization.
/// This is a simplified tree structure that Flutter can easily render.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AstNodeView {
    pub id: usize,
    pub label: String,
    pub node_type: String,
    pub value: Option<String>,
    pub children: Vec<AstNodeView>,
    pub span: Span,
}

impl AstNodeView {
    /// Convert a full program AST into a viewable tree.
    pub fn from_program(program: &Program) -> Self {
        let mut id_counter = 0;
        let children: Vec<AstNodeView> = program
            .statements
            .iter()
            .map(|s| Self::from_stmt(s, &mut id_counter))
            .collect();

        AstNodeView {
            id: id_counter,
            label: "Program".to_string(),
            node_type: "Program".to_string(),
            value: None,
            children,
            span: Span::dummy(),
        }
    }

    fn from_stmt(stmt: &Stmt, id: &mut usize) -> Self {
        *id += 1;
        let current_id = *id;

        match &stmt.kind {
            StmtKind::VarDecl { name, initializer, mutable } => {
                let mut children = vec![];
                if let Some(init) = initializer {
                    children.push(Self::from_expr(init, id));
                }
                AstNodeView {
                    id: current_id,
                    label: if *mutable { "VarDecl" } else { "ConstDecl" }.to_string(),
                    node_type: "Statement".to_string(),
                    value: Some(name.clone()),
                    children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::Assignment { target, value } => {
                AstNodeView {
                    id: current_id,
                    label: "Assignment".to_string(),
                    node_type: "Statement".to_string(),
                    value: Some(target.clone()),
                    children: vec![Self::from_expr(value, id)],
                    span: stmt.span.clone(),
                }
            }
            StmtKind::If { condition, then_branch, else_branch } => {
                let mut children = vec![Self::from_expr(condition, id)];
                *id += 1;
                let then_children: Vec<AstNodeView> = then_branch
                    .iter()
                    .map(|s| Self::from_stmt(s, id))
                    .collect();
                children.push(AstNodeView {
                    id: *id,
                    label: "ThenBlock".to_string(),
                    node_type: "Block".to_string(),
                    value: None,
                    children: then_children,
                    span: stmt.span.clone(),
                });
                if let Some(else_stmts) = else_branch {
                    *id += 1;
                    let else_children: Vec<AstNodeView> = else_stmts
                        .iter()
                        .map(|s| Self::from_stmt(s, id))
                        .collect();
                    children.push(AstNodeView {
                        id: *id,
                        label: "ElseBlock".to_string(),
                        node_type: "Block".to_string(),
                        value: None,
                        children: else_children,
                        span: stmt.span.clone(),
                    });
                }
                AstNodeView {
                    id: current_id,
                    label: "If".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::While { condition, body } => {
                let mut children = vec![Self::from_expr(condition, id)];
                *id += 1;
                let body_children: Vec<AstNodeView> = body
                    .iter()
                    .map(|s| Self::from_stmt(s, id))
                    .collect();
                children.push(AstNodeView {
                    id: *id,
                    label: "Body".to_string(),
                    node_type: "Block".to_string(),
                    value: None,
                    children: body_children,
                    span: stmt.span.clone(),
                });
                AstNodeView {
                    id: current_id,
                    label: "While".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::For { variable, iterable, body } => {
                let mut children = vec![Self::from_expr(iterable, id)];
                *id += 1;
                let body_children: Vec<AstNodeView> = body
                    .iter()
                    .map(|s| Self::from_stmt(s, id))
                    .collect();
                children.push(AstNodeView {
                    id: *id,
                    label: "Body".to_string(),
                    node_type: "Block".to_string(),
                    value: None,
                    children: body_children,
                    span: stmt.span.clone(),
                });
                AstNodeView {
                    id: current_id,
                    label: "For".to_string(),
                    node_type: "Statement".to_string(),
                    value: Some(variable.clone()),
                    children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::FnDecl { name, params, body } => {
                *id += 1;
                let body_children: Vec<AstNodeView> = body
                    .iter()
                    .map(|s| Self::from_stmt(s, id))
                    .collect();
                AstNodeView {
                    id: current_id,
                    label: "FnDecl".to_string(),
                    node_type: "Statement".to_string(),
                    value: Some(format!("{}({})", name, params.join(", "))),
                    children: body_children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::Return { value } => {
                let children = value
                    .as_ref()
                    .map(|v| vec![Self::from_expr(v, id)])
                    .unwrap_or_default();
                AstNodeView {
                    id: current_id,
                    label: "Return".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::Print { value } => {
                AstNodeView {
                    id: current_id,
                    label: "Print".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children: vec![Self::from_expr(value, id)],
                    span: stmt.span.clone(),
                }
            }
            StmtKind::Break => {
                AstNodeView {
                    id: current_id,
                    label: "Break".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children: vec![],
                    span: stmt.span.clone(),
                }
            }
            StmtKind::Continue => {
                AstNodeView {
                    id: current_id,
                    label: "Continue".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children: vec![],
                    span: stmt.span.clone(),
                }
            }
            StmtKind::Block { statements } => {
                let children: Vec<AstNodeView> = statements
                    .iter()
                    .map(|s| Self::from_stmt(s, id))
                    .collect();
                AstNodeView {
                    id: current_id,
                    label: "Block".to_string(),
                    node_type: "Block".to_string(),
                    value: None,
                    children,
                    span: stmt.span.clone(),
                }
            }
            StmtKind::ExprStmt { expr } => {
                AstNodeView {
                    id: current_id,
                    label: "ExprStmt".to_string(),
                    node_type: "Statement".to_string(),
                    value: None,
                    children: vec![Self::from_expr(expr, id)],
                    span: stmt.span.clone(),
                }
            }
        }
    }

    fn from_expr(expr: &Expr, id: &mut usize) -> Self {
        *id += 1;
        let current_id = *id;

        match &expr.kind {
            ExprKind::IntLiteral(v) => AstNodeView {
                id: current_id,
                label: "Int".to_string(),
                node_type: "Literal".to_string(),
                value: Some(v.to_string()),
                children: vec![],
                span: expr.span.clone(),
            },
            ExprKind::FloatLiteral(v) => AstNodeView {
                id: current_id,
                label: "Float".to_string(),
                node_type: "Literal".to_string(),
                value: Some(v.to_string()),
                children: vec![],
                span: expr.span.clone(),
            },
            ExprKind::StringLiteral(v) => AstNodeView {
                id: current_id,
                label: "String".to_string(),
                node_type: "Literal".to_string(),
                value: Some(format!("\"{}\"", v)),
                children: vec![],
                span: expr.span.clone(),
            },
            ExprKind::BoolLiteral(v) => AstNodeView {
                id: current_id,
                label: "Bool".to_string(),
                node_type: "Literal".to_string(),
                value: Some(v.to_string()),
                children: vec![],
                span: expr.span.clone(),
            },
            ExprKind::NullLiteral => AstNodeView {
                id: current_id,
                label: "Null".to_string(),
                node_type: "Literal".to_string(),
                value: None,
                children: vec![],
                span: expr.span.clone(),
            },
            ExprKind::Identifier(name) => AstNodeView {
                id: current_id,
                label: "Ident".to_string(),
                node_type: "Identifier".to_string(),
                value: Some(name.clone()),
                children: vec![],
                span: expr.span.clone(),
            },
            ExprKind::BinaryOp { left, op, right } => AstNodeView {
                id: current_id,
                label: "BinaryOp".to_string(),
                node_type: "Expression".to_string(),
                value: Some(op.symbol().to_string()),
                children: vec![
                    Self::from_expr(left, id),
                    Self::from_expr(right, id),
                ],
                span: expr.span.clone(),
            },
            ExprKind::UnaryOp { op, operand } => AstNodeView {
                id: current_id,
                label: "UnaryOp".to_string(),
                node_type: "Expression".to_string(),
                value: Some(op.symbol().to_string()),
                children: vec![Self::from_expr(operand, id)],
                span: expr.span.clone(),
            },
            ExprKind::Call { callee, args } => {
                let children = args.iter().map(|a| Self::from_expr(a, id)).collect();
                AstNodeView {
                    id: current_id,
                    label: "Call".to_string(),
                    node_type: "Expression".to_string(),
                    value: Some(callee.clone()),
                    children,
                    span: expr.span.clone(),
                }
            }
            ExprKind::Group(inner) => AstNodeView {
                id: current_id,
                label: "Group".to_string(),
                node_type: "Expression".to_string(),
                value: None,
                children: vec![Self::from_expr(inner, id)],
                span: expr.span.clone(),
            },
            ExprKind::Range { start, end } => AstNodeView {
                id: current_id,
                label: "Range".to_string(),
                node_type: "Expression".to_string(),
                value: None,
                children: vec![
                    Self::from_expr(start, id),
                    Self::from_expr(end, id),
                ],
                span: expr.span.clone(),
            },
        }
    }
}
