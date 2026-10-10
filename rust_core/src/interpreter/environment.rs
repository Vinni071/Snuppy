//! # Luminthor Engine — Interpreter Environment
//!
//! Manages variable scoping and the execution environment.
//! Supports nested lexical scopes with parent chain traversal,
//! and can produce snapshots for the didactic execution trace.

use std::collections::HashMap;
use serde::{Deserialize, Serialize};

/// Runtime values in the Lumi language.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum Value {
    Int(i64),
    Float(f64),
    String(String),
    Bool(bool),
    Null,
    /// A function value storing parameter names and body statement indices.
    Function {
        name: String,
        params: Vec<String>,
        /// Index into the program's statement list where the function body lives.
        /// The actual body is looked up from the AST during execution.
        body_index: usize,
    },
}

impl Value {
    /// Get the type name for display purposes.
    pub fn type_name(&self) -> &str {
        match self {
            Value::Int(_) => "inteiro",
            Value::Float(_) => "decimal",
            Value::String(_) => "texto",
            Value::Bool(_) => "booleano",
            Value::Null => "nulo",
            Value::Function { .. } => "função",
        }
    }

    /// Display value for the user.
    pub fn display(&self) -> String {
        match self {
            Value::Int(v) => v.to_string(),
            Value::Float(v) => format!("{}", v),
            Value::String(v) => v.clone(),
            Value::Bool(v) => v.to_string(),
            Value::Null => "null".to_string(),
            Value::Function { name, params, .. } => {
                format!("fn {}({})", name, params.join(", "))
            }
        }
    }

    /// Check if value is truthy.
    pub fn is_truthy(&self) -> bool {
        match self {
            Value::Bool(v) => *v,
            Value::Null => false,
            Value::Int(v) => *v != 0,
            Value::Float(v) => *v != 0.0,
            Value::String(v) => !v.is_empty(),
            Value::Function { .. } => true,
        }
    }
}

impl std::fmt::Display for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.display())
    }
}

/// A single scope level containing variable bindings.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScopeSnapshot {
    /// Depth of this scope (0 = global).
    pub depth: usize,
    pub is_function_scope: bool,
    pub variables: HashMap<String, Value>,
}

/// A single scope level containing variable bindings.
#[derive(Debug, Clone)]
pub struct Scope {
    variables: HashMap<String, Value>,
    /// Whether this scope is a function scope (affects return behavior)
    pub is_function_scope: bool,
}

impl Scope {
    pub fn new(is_function_scope: bool) -> Self {
        Self {
            variables: HashMap::new(),
            is_function_scope,
        }
    }

    pub fn get(&self, name: &str) -> Option<&Value> {
        self.variables.get(name)
    }

    pub fn set(&mut self, name: String, value: Value) {
        self.variables.insert(name, value);
    }

    pub fn has(&self, name: &str) -> bool {
        self.variables.contains_key(name)
    }

    pub fn snapshot(&self) -> HashMap<String, Value> {
        self.variables.clone()
    }
}

/// The execution environment managing a chain of nested scopes.
#[derive(Debug, Clone)]
pub struct Environment {
    scopes: Vec<Scope>,
}

impl Environment {
    /// Create a new environment with a global scope.
    pub fn new() -> Self {
        Self {
            scopes: vec![Scope::new(false)],
        }
    }

    /// Push a new scope onto the scope chain.
    pub fn push_scope(&mut self, is_function_scope: bool) {
        self.scopes.push(Scope::new(is_function_scope));
    }

    /// Pop the most recent scope.
    pub fn pop_scope(&mut self) {
        if self.scopes.len() > 1 {
            self.scopes.pop();
        }
    }

    /// Define a new variable in the current scope.
    pub fn define(&mut self, name: String, value: Value) {
        if let Some(scope) = self.scopes.last_mut() {
            scope.set(name, value);
        }
    }

    /// Look up a variable by walking the scope chain.
    pub fn get(&self, name: &str) -> Option<&Value> {
        for scope in self.scopes.iter().rev() {
            if let Some(val) = scope.get(name) {
                return Some(val);
            }
        }
        None
    }

    /// Assign a value to an existing variable (must already be defined).
    pub fn assign(&mut self, name: &str, value: Value) -> bool {
        for scope in self.scopes.iter_mut().rev() {
            if scope.has(name) {
                scope.set(name.to_string(), value);
                return true;
            }
        }
        false
    }

    /// Get the current scope depth (0 = global).
    pub fn depth(&self) -> usize {
        self.scopes.len() - 1
    }

    /// Snapshot all variables across all scopes for the execution trace.
    pub fn snapshot_all(&self) -> HashMap<String, Value> {
        let mut vars = HashMap::new();
        for scope in &self.scopes {
            for (name, value) in &scope.snapshot() {
                vars.insert(name.clone(), value.clone());
            }
        }
        vars
    }

    /// Snapshot variables grouped by scope depth.
    pub fn snapshot_by_scope(&self) -> Vec<ScopeSnapshot> {
        self.scopes
            .iter()
            .enumerate()
            .map(|(depth, scope)| ScopeSnapshot {
                depth,
                is_function_scope: scope.is_function_scope,
                variables: scope.snapshot(),
            })
            .collect()
    }

    /// Check if we're inside a function scope.
    pub fn in_function(&self) -> bool {
        self.scopes.iter().rev().any(|s| s.is_function_scope)
    }
}

impl Default for Environment {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_global_scope() {
        let mut env = Environment::new();
        env.define("x".to_string(), Value::Int(42));
        assert_eq!(env.get("x"), Some(&Value::Int(42)));
    }

    #[test]
    fn test_nested_scope() {
        let mut env = Environment::new();
        env.define("x".to_string(), Value::Int(1));
        env.push_scope(false);
        env.define("y".to_string(), Value::Int(2));

        assert_eq!(env.get("x"), Some(&Value::Int(1))); // visible from parent
        assert_eq!(env.get("y"), Some(&Value::Int(2)));
        assert_eq!(env.depth(), 1);

        env.pop_scope();
        assert_eq!(env.get("y"), None); // no longer visible
        assert_eq!(env.depth(), 0);
    }

    #[test]
    fn test_variable_shadowing() {
        let mut env = Environment::new();
        env.define("x".to_string(), Value::Int(1));
        env.push_scope(false);
        env.define("x".to_string(), Value::Int(2));

        assert_eq!(env.get("x"), Some(&Value::Int(2)));
        env.pop_scope();
        assert_eq!(env.get("x"), Some(&Value::Int(1)));
    }

    #[test]
    fn test_assign_in_parent_scope() {
        let mut env = Environment::new();
        env.define("x".to_string(), Value::Int(1));
        env.push_scope(false);

        assert!(env.assign("x", Value::Int(42)));
        assert_eq!(env.get("x"), Some(&Value::Int(42)));
    }

    #[test]
    fn test_snapshot() {
        let mut env = Environment::new();
        env.define("a".to_string(), Value::Int(1));
        env.push_scope(false);
        env.define("b".to_string(), Value::Int(2));

        let snapshot = env.snapshot_all();
        assert_eq!(snapshot.len(), 2);
        assert_eq!(snapshot.get("a"), Some(&Value::Int(1)));
        assert_eq!(snapshot.get("b"), Some(&Value::Int(2)));
    }

    #[test]
    fn test_value_display() {
        assert_eq!(Value::Int(42).display(), "42");
        assert_eq!(Value::Float(3.14).display(), "3.14");
        assert_eq!(Value::String("hello".to_string()).display(), "hello");
        assert_eq!(Value::Bool(true).display(), "true");
        assert_eq!(Value::Null.display(), "null");
    }

    #[test]
    fn test_truthiness() {
        assert!(Value::Bool(true).is_truthy());
        assert!(!Value::Bool(false).is_truthy());
        assert!(!Value::Null.is_truthy());
        assert!(Value::Int(1).is_truthy());
        assert!(!Value::Int(0).is_truthy());
        assert!(Value::String("hi".to_string()).is_truthy());
        assert!(!Value::String("".to_string()).is_truthy());
    }
}
