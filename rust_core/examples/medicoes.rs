//! Medições do motor Lumi conforme o protocolo da monografia
//! (Seção "Protocolo de medições", capítulo de verificação complementar).
//!
//! Executar com:
//!   cargo run --release --example medicoes --manifest-path rust_core/Cargo.toml
//!
//! Tempo: programas de L linhas (1 declaração, L-2 atribuições, 1 impressão);
//! análise = lexer + parser + semântico; interpretação sobre a AST pronta.
//! 10 aquecimentos e 30 amostras por tamanho; mediana e intervalo.
//!
//! Memória: alocador contador global. Mede bytes de heap ainda vivos após a
//! interpretação (resultado retido, que contém o rastro) e o pico durante a
//! interpretação, ambos em relação à referência imediatamente anterior.
//! Não é RSS do processo nem heap Dart.

use std::alloc::{GlobalAlloc, Layout, System};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Instant;

use ide_engine::interpreter::Interpreter;

struct Contador;

static ATUAL: AtomicUsize = AtomicUsize::new(0);
static PICO: AtomicUsize = AtomicUsize::new(0);

unsafe impl GlobalAlloc for Contador {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let p = System.alloc(layout);
        if !p.is_null() {
            let novo = ATUAL.fetch_add(layout.size(), Ordering::Relaxed) + layout.size();
            PICO.fetch_max(novo, Ordering::Relaxed);
        }
        p
    }
    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        System.dealloc(ptr, layout);
        ATUAL.fetch_sub(layout.size(), Ordering::Relaxed);
    }
    unsafe fn realloc(&self, ptr: *mut u8, layout: Layout, new_size: usize) -> *mut u8 {
        let p = System.realloc(ptr, layout, new_size);
        if !p.is_null() {
            if new_size >= layout.size() {
                let novo = ATUAL.fetch_add(new_size - layout.size(), Ordering::Relaxed)
                    + (new_size - layout.size());
                PICO.fetch_max(novo, Ordering::Relaxed);
            } else {
                ATUAL.fetch_sub(layout.size() - new_size, Ordering::Relaxed);
            }
        }
        p
    }
}

#[global_allocator]
static GLOBAL: Contador = Contador;

const AQUECIMENTO: usize = 10;
const AMOSTRAS: usize = 30;

/// Programa com L linhas: `var x = 0;`, L-2 vezes `x = x + 1;`, `print(x);`.
fn programa_linhas(l: usize) -> String {
    let mut s = String::from("var x = 0;\n");
    for _ in 0..l.saturating_sub(2) {
        s.push_str("x = x + 1;\n");
    }
    s.push_str("print(x);\n");
    s
}

/// Programa sem laço com uma declaração e `n - 1` atribuições.
fn programa_passos(n: usize) -> String {
    let mut s = String::from("var x = 0;\n");
    for _ in 0..n.saturating_sub(1) {
        s.push_str("x = x + 1;\n");
    }
    s
}

fn analisar(src: &str) -> ide_engine::ast::Program {
    let (tokens, erros) = ide_engine::lexer::tokenize(src);
    assert!(erros.is_empty(), "erros léxicos: {:?}", erros);
    let prog = ide_engine::parser::parse(tokens, src).expect("falha sintática");
    ide_engine::semantic::analyze(&prog).expect("falha semântica");
    prog
}

fn estatisticas(mut v: Vec<f64>) -> (f64, f64, f64) {
    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let n = v.len();
    let med = if n % 2 == 0 { (v[n / 2 - 1] + v[n / 2]) / 2.0 } else { v[n / 2] };
    (med, v[0], v[n - 1])
}

fn ms(d: std::time::Duration) -> f64 {
    d.as_secs_f64() * 1000.0
}

fn main() {
    println!("# Tempo (ms) — {AQUECIMENTO} aquecimentos, {AMOSTRAS} amostras");
    println!("ensaio;linhas;mediana_ms;min_ms;max_ms");
    for &l in &[10usize, 100, 1000] {
        let src = programa_linhas(l);
        assert_eq!(src.lines().count(), l);

        for _ in 0..AQUECIMENTO {
            std::hint::black_box(analisar(&src));
        }
        let mut t = Vec::with_capacity(AMOSTRAS);
        for _ in 0..AMOSTRAS {
            let i = Instant::now();
            std::hint::black_box(analisar(&src));
            t.push(ms(i.elapsed()));
        }
        let (m, a, b) = estatisticas(t);
        println!("analise;{l};{m:.4};{a:.4};{b:.4}");

        let prog = analisar(&src);
        for _ in 0..AQUECIMENTO {
            std::hint::black_box(Interpreter::new().interpret(&prog));
        }
        let mut t = Vec::with_capacity(AMOSTRAS);
        let mut saida = String::new();
        for _ in 0..AMOSTRAS {
            let mut interp = Interpreter::new();
            let i = Instant::now();
            let r = interp.interpret(&prog);
            t.push(ms(i.elapsed()));
            assert!(r.errors.is_empty(), "erros: {:?}", r.errors);
            saida = r.output;
        }
        let (m, a, b) = estatisticas(t);
        println!("interpretacao;{l};{m:.4};{a:.4};{b:.4};saida={}", saida.trim());
    }

    println!();
    println!("# Memória de heap do rastro (bytes) — alocador contador");
    println!("passos_alvo;passos_registrados;limite_passos;erros;retido_bytes;pico_bytes");
    for &n in &[100usize, 1000, 10_000] {
        let src = programa_passos(n);
        let prog = analisar(&src);
        // Limite padrão do app (10.000) e limite ampliado apenas para medir.
        for &limite in &[10_000usize, n + 10] {
            let mut interp = Interpreter::new().with_max_steps(limite);
            let base = ATUAL.load(Ordering::SeqCst);
            PICO.store(base, Ordering::SeqCst);
            let r = interp.interpret(&prog);
            let retido = ATUAL.load(Ordering::SeqCst) as isize - base as isize;
            let pico = PICO.load(Ordering::SeqCst) - base;
            drop(interp);
            println!(
                "{n};{};{limite};{};{retido};{pico}",
                r.execution_trace.len(),
                r.errors.len()
            );
            drop(r);
        }
    }
}
