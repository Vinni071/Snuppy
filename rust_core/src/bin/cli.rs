//! # Snuppy Engine CLI
//!
//! Command-line interface for testing the compiler engine without Flutter.
//! Supports tokenizing, parsing, analyzing, and running Lumi source code.
//!
//! Usage:
//!   ide-cli "var x = 10; print(x)"
//!   ide-cli --tokens-only "var x = 10"
//!   ide-cli --ast-only "var x = 10"

use std::env;
use ide_engine::api;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        print_usage();
        return;
    }

    let mut source = String::new();
    let mut mode = Mode::Full;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--help" | "-h" => {
                print_usage();
                return;
            }
            "--tokens-only" | "-t" => {
                mode = Mode::TokensOnly;
            }
            "--ast-only" | "-a" => {
                mode = Mode::AstOnly;
            }
            "--json" | "-j" => {
                mode = Mode::Json;
            }
            _ => {
                source = args[i].clone();
            }
        }
        i += 1;
    }

    if source.is_empty() {
        eprintln!("Error: No source code provided.");
        print_usage();
        return;
    }

    // Replace escaped newlines for convenience
    let source = source.replace("\\n", "\n");

    match mode {
        Mode::TokensOnly => run_tokens_only(&source),
        Mode::AstOnly => run_ast_only(&source),
        Mode::Json => run_json(&source),
        Mode::Full => run_full(&source),
    }
}

enum Mode {
    Full,
    TokensOnly,
    AstOnly,
    Json,
}

fn print_usage() {
    println!(
        r#"
╔══════════════════════════════════════════════╗
║          Snuppy Engine CLI v0.1.0               ║
║    Educational Compiler for Lumi Language    ║
╚══════════════════════════════════════════════╝

USAGE:
    ide-cli [OPTIONS] "source code"

OPTIONS:
    -t, --tokens-only   Show only the token stream
    -a, --ast-only      Show only the AST
    -j, --json          Output full result as JSON
    -h, --help          Show this help message

EXAMPLES:
    ide-cli "var x = 10\nprint(x)"
    ide-cli --tokens-only "var x = 10"
    ide-cli --ast-only "if x < 10 {{ print(x) }}"
    ide-cli --json "var x = 1 + 2"
"#
    );
}

fn run_tokens_only(source: &str) {
    let (tokens, errors) = api::tokenize_only(source);

    println!("\n═══ TOKENS ═══\n");
    println!(
        "{:<5} {:<25} {:<20} {:<10}",
        "LINE", "TYPE", "LEXEME", "SPAN"
    );
    println!("{}", "─".repeat(60));

    for token in &tokens {
        println!(
            "{:<5} {:<25} {:<20} {}:{}",
            token.line, token.token_type, token.lexeme, token.start, token.end
        );
    }

    if !errors.is_empty() {
        println!("\n═══ ERRORS ═══\n");
        for err in &errors {
            println!("  ❌ {}", err);
        }
    }

    println!("\nTotal: {} tokens", tokens.len());
}

fn run_ast_only(source: &str) {
    match api::parse_only(source) {
        Ok(ast) => {
            println!("\n═══ AST ═══\n");
            print_ast_node(&ast, 0);
        }
        Err(errors) => {
            println!("\n═══ PARSE ERRORS ═══\n");
            for err in &errors {
                println!("  ❌ {}", err);
            }
        }
    }
}

fn run_json(source: &str) {
    let result = api::process_source(source);
    match serde_json::to_string_pretty(&result) {
        Ok(json) => println!("{}", json),
        Err(e) => eprintln!("JSON serialization error: {}", e),
    }
}

fn run_full(source: &str) {
    println!("\n╔══════════════════════════════════════════════╗");
    println!("║          Snuppy Engine — Full Pipeline          ║");
    println!("╚══════════════════════════════════════════════╝");

    let result = api::process_source(source);

    // ── Tokens ──
    println!("\n═══ TOKENS ({}) ═══\n", result.tokens.len());
    for token in &result.tokens {
        println!(
            "  [{:>2}:{:<2}] {:<25} {}",
            token.line, token.column, token.token_type, token.lexeme
        );
    }

    // ── AST ──
    if let Some(ref ast) = result.ast {
        println!("\n═══ AST ═══\n");
        print_ast_node(ast, 1);
    }

    // ── Output ──
    if !result.output.is_empty() {
        println!("\n═══ OUTPUT ═══\n");
        print!("  {}", result.output.replace('\n', "\n  "));
        println!();
    }

    // ── Execution Trace ──
    if !result.execution_trace.is_empty() {
        println!(
            "\n═══ EXECUTION TRACE ({} steps) ═══\n",
            result.execution_trace.len()
        );
        for (i, step) in result.execution_trace.iter().enumerate() {
            println!(
                "  Step {}: [L{}] {} — {}",
                i + 1,
                step.line,
                step.action,
                step.description
            );
            if let Some(ref output) = step.output {
                println!("         ↳ output: {}", output.trim());
            }
        }
    }

    // ── Memory State ──
    if !result.memory_state.is_empty() {
        println!("\n═══ FINAL MEMORY STATE ═══\n");
        let mut vars: Vec<_> = result.memory_state.iter().collect();
        vars.sort_by_key(|(k, _)| *k);
        for (name, value) in &vars {
            println!(
                "  {} = {} ({})",
                name,
                value.display(),
                value.type_name()
            );
        }
    }

    // ── Errors ──
    if !result.errors.is_empty() {
        println!("\n═══ ERRORS ═══\n");
        for err in &result.errors {
            println!("  ❌ {}", err);
            println!("     {}", err.educational_message().replace('\n', "\n     "));
            println!();
        }
    }

    // ── Summary ──
    println!(
        "\n{}\n",
        if result.success {
            "✅ Program executed successfully!"
        } else {
            "❌ Program finished with errors."
        }
    );
}

/// Pretty-print an AST node with tree-style indentation.
fn print_ast_node(node: &ide_engine::ast::AstNodeView, depth: usize) {
    let indent = "  ".repeat(depth);
    let connector = if depth > 0 { "├─ " } else { "" };

    let value_str = node
        .value
        .as_ref()
        .map(|v| format!(": {}", v))
        .unwrap_or_default();

    println!("{}{}{}{}", indent, connector, node.label, value_str);

    for child in &node.children {
        print_ast_node(child, depth + 1);
    }
}
