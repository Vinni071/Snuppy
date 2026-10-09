//! # Luminthor Engine
//!
//! Educational compiler engine for the Luminthor mobile programming environment.
//! Provides a complete pipeline from source code to execution, with full
//! introspection at each stage for didactic visualization.
//!
//! ## Pipeline
//!
//! ```text
//! Source Code → Lexer → Tokens → Parser → AST → Semantic Analysis → Interpreter → Output
//! ```
//!
//! Each stage produces serializable output suitable for visualization in
//! the Flutter UI, enabling students to see exactly how their code is
//! processed at every step.

mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

pub mod api;
pub mod ast;
pub mod errors;
pub mod interpreter;
pub mod lexer;
pub mod parser;
pub mod semantic;

// Re-export the public API for convenience
pub use api::{process_source, parse_only, tokenize_only, CompileResult};
