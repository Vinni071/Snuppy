//! Reprodução dos cenários T2/T3 com os programas exatos do formulário aplicado.
//! cargo run --example reproducao_t3 --manifest-path rust_core/Cargo.toml
use ide_engine::api::process_source;

const T2: &str = "var total = 10 + 5;\nprint(total;";
const T2_CORRIGIDA: &str = "var total = 10 + 5;\nprint(total);";
const T3: &str = "var total = 12;\n\nvar quantidade = 0;\n\nvar media = total / quantidade;\n\nprint(media);";

fn executar(nome: &str, fonte: &str) {
    let r = process_source(fonte);
    println!("== {nome}");
    println!("sucesso: {} | saída: {:?} | passos no rastro: {}", r.success, r.output.trim(), r.execution_trace.len());
    for e in &r.errors {
        println!("erro: {e}");
    }
    println!();
}

fn main() {
    executar("1. T2 sem correção", T2);
    executar("2. T3 substitui integralmente T2", T3);
    executar("3. T2 sem correção permanece e T3 é acrescentada", &format!("{T2}\n{T3}"));
    executar("4. T2 corrigida (controle)", T2_CORRIGIDA);
    executar("5. T3 substitui T2 corrigida", T3);
}
