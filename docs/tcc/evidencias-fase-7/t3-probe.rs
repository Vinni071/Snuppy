use ide_engine::api::process_source;
use serde_json::json;

fn main() {
    let t2 = "var total = 10 + 5;\nprint(total;";
    let t3 = "var total = 12;\nvar quantidade = 0;\nvar resultado = total / quantidade;\nprint(resultado);";
    let scenarios = [
        ("T2_sem_correcao", t2.to_string()),
        ("T3_substitui_T2_no_mesmo_processo", t3.to_string()),
        ("T2_mantida_e_T3_acrescentada", format!("{}\n{}", t2, t3)),
        ("T2_corrigida_controle", "var total = 10 + 5;\nprint(total);".to_string()),
        ("T3_apos_T2_corrigida_no_mesmo_processo", t3.to_string()),
    ];
    let mut records = Vec::new();
    for (name, source) in scenarios {
        let result = process_source(&source);
        records.push(json!({"cenario": name, "fonte": source, "resultado": result}));
    }
    println!("{}", serde_json::to_string_pretty(&records).unwrap());
}
