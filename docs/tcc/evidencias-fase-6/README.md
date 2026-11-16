# Evidências da revisão do desenvolvimento — 15/11/2026

Código inspecionado: `2e33f7ed800636fa0068b663e15789a693d9af1b`.
Estes registros são da verificação atual em Linux. Não identificam o APK da coleta.

- `ambiente.json`: sistema e versões de Flutter, Dart, Rust e Cargo.
- `cargo-build.txt` e `cargo-test.txt`: compilação e aprovação de 68 testes Rust.
- `flutter-pub-get.txt`: dependências preparadas sem rede na cópia dos arquivos versionados.
- `flutter-test-coverage.txt`: aprovação de 159 testes Flutter, incluindo FFI real.
- `flutter-analyze.txt`: análise estática sem problemas apontados.
- `flutter-lcov.info.gz`: LCOV original compactado, com 71 arquivos, 3.764/4.569 linhas (82,38%).
- `cobertura-flutter-resumo.json`: contagens por arquivo. Excluindo explicitamente `lib/src/rust/`, o recorte é 63 arquivos, 3.548/3.917 linhas (90,58%). As medidas cobrem apenas linhas Dart presentes no LCOV; não medem ramos ou Rust.
- `llvm-cov-disponibilidade.txt`: `cargo llvm-cov` não instalado. Isso não é uma falha dos testes Rust, que passaram no comando anterior.
- `ensaios-cli.json.gz`: fonte e retorno JSON completo de 33 programas; inclui as falhas esperadas e um rastro de 10.000 eventos. Mapas podem aparecer em ordens diferentes na serialização.
- `reproduzir-ensaios.py` e `reproducao-cli.json`: execução de conferência dos 33 resultados. A comparação usa conteúdo dos objetos, não a ordem dos mapas.
- `identificacao.json`: URL canônica e privacidade do repositório verificadas pelo conector GitHub; commit histórico confirmado remotamente. Não contém credenciais ou dados de participantes.

Na raiz do projeto, com as dependências disponíveis:

```sh
cargo build --offline --manifest-path rust_core/Cargo.toml
cargo test --offline --manifest-path rust_core/Cargo.toml
flutter pub get --offline
flutter analyze --no-pub
flutter test --no-pub --coverage --reporter expanded
python3 docs/tcc/evidencias-fase-6/reproduzir-ensaios.py
```

A suíte Flutter foi executada em `/tmp/luminthor-revisao-fase6/aplicativo`, cópia dos
arquivos versionados, com `libide_engine.so` compilada da mesma revisão. A compilação
e os testes Cargo usaram o projeto local e seus caches. Nenhum fonte de `lib/`,
`rust_core/` ou `test/` foi alterado. O SDK Flutter precisou atualizar o próprio cache;
isso não constituiu alteração do aplicativo.

As medições do protocolo proposto para APK, abertura, tempos por fase e memória não
foram realizadas. Não há dados de novos participantes, ensaios Android físicos,
conclusões de aprendizagem ou nova identificação retroativa do APK distribuído.
