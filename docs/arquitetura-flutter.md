# Arquitetura do app Flutter

Feature-first + MVVM + Clean Architecture pragmática, com Riverpod para estado
e injeção de dependências e GoRouter para navegação.

```text
lib/
├── main.dart                 # Abre o storage e inicia o app
├── app/
│   ├── app.dart              # MyApp: splash → erro de inicialização ou router
│   ├── bootstrap/            # Inicialização do Hive e do motor Rust (FFI)
│   ├── router/               # AppRouter + AppRoutes (rotas tipadas)
│   └── theme/                # AppTheme, EditorPalette, cores
├── core/
│   ├── storage/              # KeyValueStore (contrato) + HiveKeyValueStore
│   ├── errors/               # reportError: log técnico centralizado
│   ├── compiler/             # Localização da biblioteca nativa do motor
│   ├── branding/             # Logo e assets da marca
│   └── utils/                # Utilitários puros (ex.: datas relativas)
├── shared/widgets/           # Widgets reutilizáveis entre features (PressScale)
├── features/
│   ├── workspace/            # Documentos .lumi: entidade, repositório, import/export
│   ├── editor/               # Editor, compilação, tokens, AST e depurador
│   ├── home/                 # Tela inicial (seções, busca, templates)
│   ├── learning/             # Trilha Lumi: lições e progresso
│   ├── settings/             # Preferências (tema, fonte)
│   ├── splash/               # Animação de abertura
│   └── templates/            # Catálogo de templates de código
└── src/rust/                 # GERADO por flutter_rust_bridge — não editar
```

Cada feature usa apenas as camadas de que precisa:

- `domain/` — Dart puro: entidades, regras e contratos de repositório.
- `data/` — implementações (repositórios sobre `KeyValueStore`, mappers, FFI, file picker).
- `presentation/` — `screens/`, `widgets/` e `viewmodels/` (Riverpod `Notifier`).

## Regras de dependência

- Widgets falam com ViewModels; ViewModels usam repositórios via providers.
- `domain/` não importa `data/` nem `presentation/`.
- Infraestrutura (Hive, FFI, file picker) só aparece em `data/`, `core/` e `app/bootstrap/`.
- Para trocar uma implementação em testes, sobrescreva o provider
  (`keyValueStoreProvider`, `sourceCompilerProvider`, `workspaceFileServiceProvider`,
  `splashPlayerFactoryProvider`).

## Persistência

Tudo fica numa única box Hive (`ide_box`). As chaves fazem parte do formato salvo
nos dispositivos e estão declaradas nos repositórios (`Local*Repository`); não as
renomeie sem uma migração.

## Tipos do motor Rust

`CompileResult`, `TokenInfo`, `AstNodeView`, `ExecutionStep` etc. são classes Dart
imutáveis geradas pelo flutter_rust_bridge e usadas diretamente como modelo
compartilhado; duplicá-las em entidades paralelas não traria benefício.

