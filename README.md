# Snuppy — Compilador e Interpretador Didático Mobile-First

O **Snuppy** é um ambiente de desenvolvimento integrado (IDE) educacional projetado para ensinar lógica de programação, compiladores e execução de código de forma altamente interativa e visual. 

Ao invés de ser apenas um editor com saída de texto, o Snuppy permite aos estudantes visualizarem o fluxo de execução interna dos seus programas na linguagem de programação **Lumi**.

---

## ✨ Funcionalidades Principais

- 📝 **Editor Lumi com Highlight**: Destaque de sintaxe regex-baseado em tempo real com numeração e destaque visual da linha atual sob depuração.
- ⚙️ **Engine de Alta Performance (Rust)**: O compilador e interpretador do Lumi são escritos em Rust para máxima velocidade e correção matemática.
- 📊 **Visualizador de Tokens**: Tabela interativa mostrando o resultado da análise léxica (*Lexer*) com coordenadas exatas (linha/coluna) e classificação de cada lexema.
- 🌳 **Árvore AST Dinâmica**: Visualizador gráfico interativo da Árvore de Sintaxe Abstrata gerada pelo *Parser*. É possível colapsar e expandir nós.
- 🐞 **Depurador Didático Passo a Passo**:
  - Linha do tempo interativa para retroceder ou avançar a execução do programa no tempo.
  - **Memory Inspector**: Veja o estado atual de todas as variáveis na memória com seus respectivos valores e tipos estáticos (`int`, `float`, `string`, `bool`, `função`).
  - **Call Stack & Scopes**: Acompanhe o empilhamento das chamadas de funções e as profundidades de escopo isoladas do programa.
- 📟 **Painel de Diagnósticos**: Console de saída padrão (`stdout`) e aba de diagnósticos ricos, exibindo a linha e coluna do erro com indicadores gráficos (`^`), sugestões semânticas inteligentes (*did you mean?*) e pilhas de erro detalhadas.

---

## 🛠️ Requisitos de Sistema

Para compilar e rodar o projeto localmente, certifique-se de ter instalado:

1. **Flutter SDK** (versão 3.16 ou superior)
2. **Rust & Cargo** (última versão estável)
3. **Dependências do Linux Desktop** (necessárias para build nativo do Flutter no Linux):
   ```bash
   sudo apt update
   sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev lld libstdc++-12-dev build-essential
   ```
4. **Gerador de Código FFI**:
   ```bash
   cargo install flutter_rust_bridge_codegen --version 2.12.0
   ```

---

## 🚀 Como Executar o Projeto

### Comandos Rápidos

```bash
# 1. Compilar a engine Rust
cd rust_core && cargo build && cd ..

# 2. (Opcional) Gerar bindings FFI se alterar o Rust
# flutter_rust_bridge_codegen generate

# 3. Rodar testes
flutter test

# 4. Executar o app no Linux Desktop
env -i HOME="$HOME" PATH="$PATH" DISPLAY="$DISPLAY" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" LD_LIBRARY_PATH="" flutter run -d linux
```

> **Nota:** O comando com `env -i ...` limpa variáveis de ambiente que podem causar conflito com bibliotecas do sistema (comum ao usar Flutter via Snap ou em conjunto com Flatpak).

### Passo a Passo

Siga os passos abaixo para compilar a biblioteca nativa em Rust e rodar o aplicativo:

### Passo 1: Compilar a Engine em Rust
Navegue até a pasta `rust_core` e compile a biblioteca dinâmica:
```bash
cd rust_core
cargo build
cd ..
```
Isso criará o arquivo dinâmico em `rust_core/target/debug/libide_engine.so`.

### Passo 2 (Opcional): Gerar Bindings FFI
Caso altere alguma estrutura exposta no Rust (em `rust_core/src/api.rs`), gere novamente os arquivos de comunicação Dart-Rust:
```bash
flutter_rust_bridge_codegen generate
```

### Passo 3: Executar a Suíte de Testes
Certifique-se de que tudo está compilado e funcionando executando os testes unitários e de integração:
```bash
flutter test
```

### Passo 4: Executar o Aplicativo
Execute o aplicativo Flutter no Linux Desktop (ou em um dispositivo móvel conectado):
```bash
flutter run -d linux
```

---

## 🔍 Resolução de Problemas Comuns

### Erro: `Failed to find any of [ld.lld, ld] in LocalDirectory: '/snap/flutter/...'`
Esse erro ocorre comumente no Linux ao utilizar o Flutter instalado via **Snap**, pois ele executa dentro de um sandbox e pode ter dificuldades para localizar o vinculador (`lld` ou `ld`) do clang no sistema.

**Solução:**
1. Instale o vinculador `lld` e o compilador `clang` no seu sistema hospedeiro:
   ```bash
   sudo apt install lld clang
   ```
2. Caso o erro persista com a versão do Snap, a solução recomendada para desenvolvimento de desktop nativo com FFI é usar a instalação oficial manual do Flutter (baixando o tar.xz do site oficial e adicionando ao seu `PATH`), o que evita restrições de sandbox do Snap.

### Erro ao rodar na Web (Chrome): `The Dart compiler exited unexpectedly`
A engine do compilador didático utiliza FFI para comunicação direta de memória com código de máquina nativo (`.so` / `.dll` / `.dylib`). A execução padrão do Chrome web não suporta carregamento de binários ELF do Linux diretamente. Para rodar na web, a engine Rust deve ser compilada para WebAssembly (WASM). **Para testes rápidos e depuração completa, execute o projeto na plataforma nativa Desktop (Linux) ou Mobile (Android/iOS).**
