# Luminthor — Compilador e Interpretador Didático Mobile-First

O **Luminthor** é um ambiente de desenvolvimento integrado (IDE) educacional projetado para ensinar lógica de programação, compiladores e execução de código de forma altamente interativa e visual.

Ao invés de ser apenas um editor com saída de texto, o Luminthor permite aos estudantes visualizarem o fluxo de execução interna dos seus programas na linguagem de programação **Lumi**.

---

## ✨ Funcionalidades Principais

- 🌱 **Trilha Lumi**: Roadmap visual com 6 módulos e 18 etapas, de algoritmos e variáveis até funções, depuração e um projeto final. Cada aula tem explicação, exemplo executável, desafio no editor e uma pergunta de compreensão que libera a próxima etapa. O progresso, os pontos e as conquistas são salvos no dispositivo; revisões não duplicam XP. A prática no editor é livre e preserva o arquivo de cada aula.
- 🏠 **Home responsiva**: Crie um arquivo, importe códigos `.lumi` ou `.txt`, pesquise arquivos recentes e explore templates por assunto. Disponível nos temas claro e escuro.
- ⚡ **Identidade Luminthor**: Logos vetoriais e ícones próprios, com splash em vídeo correspondente ao tema. A animação pode ser pulada; em caso de falha na reprodução, a logo em SVG mantém a abertura do app funcionando.
- 💾 **Arquivos independentes**: O código é salvo automaticamente no dispositivo pelo Luminthor. Arquivos anteriores são preservados na lista de recentes; no editor, use **Exportar arquivo** para salvar uma cópia fora do aplicativo.
- 📝 **Editor Lumi com Highlight**: Destaque de sintaxe regex-baseado em tempo real com numeração e destaque visual da linha atual sob depuração.
- ⌨️ **Atalhos acima do teclado**: Barra flutuante com rolagem horizontal para indentação, símbolos e palavras-chave de Lumi. Parênteses, chaves, aspas e `print` envolvem a seleção ou posicionam o cursor para completar o código, com salvamento automático.
- 💡 **Autocomplete**: Ao digitar, o editor sugere palavras-chave de Lumi e as variáveis, constantes, parâmetros e funções visíveis naquele ponto do código. Toque em uma sugestão ou use `↑`/`↓`, `Enter` ou `Tab` e `Esc` no teclado físico.
- ⚙️ **Engine de Alta Performance (Rust)**: O compilador e interpretador do Lumi são escritos em Rust para máxima velocidade e correção matemática.
- 📊 **Visualizador de Tokens**: Tabela interativa mostrando o resultado da análise léxica (*Lexer*) com coordenadas exatas (linha/coluna) e classificação de cada lexema.
- 🌳 **Árvore AST Dinâmica**: Visualizador gráfico interativo da Árvore de Sintaxe Abstrata gerada pelo *Parser*. É possível colapsar e expandir nós.
- 🐞 **Depurador Didático Passo a Passo**:
  - Linha do tempo interativa para retroceder ou avançar a execução do programa no tempo.
  - **Memory Inspector**: Veja os valores e os tipos em tempo de execução (`inteiro`, `decimal`, `texto`, `booleano`, `nulo`, `função`), com as variáveis separadas por escopo e preservação de nomes sombreados.
  - **Call Stack & Scopes**: Acompanhe o empilhamento das chamadas de funções e as profundidades de escopo isoladas do programa.
  - **Saída acumulada**: O console acompanha o passo selecionado, incluindo as impressões anteriores; retroceder remove da visualização as saídas posteriores.
- 📟 **Painel de Diagnósticos**: Console de saída padrão (`stdout`) e aba de diagnósticos ricos, exibindo a linha e coluna do erro com indicadores gráficos (`^`), sugestões semânticas inteligentes (*did you mean?*) e pilhas de erro detalhadas.

---

## 📁 Estrutura do Projeto

```text
.
├── lib/            # App Flutter: core/, features/ e bindings gerados (src/rust/)
├── rust_core/      # Engine da linguagem Lumi em Rust
├── test/           # Testes Flutter
├── assets/         # Logos, ícones e vídeos de abertura (branding/)
├── tool/           # Scripts de configuração e geração de branding
├── docs/
│   ├── avaliacao-luminthor/  # Instrumentos da avaliação com estudantes
│   ├── checkpoint/           # Registro do checkpoint e logs de validação
│   └── tcc/                  # Análise e roteiro de finalização do TCC
├── output/         # Entregáveis gerados (PDF, DOCX, ZIP)
├── TCC_Teorico/    # Texto do TCC em LaTeX e referências
└── android/ ios/ linux/ macos/ web/ windows/  # Plataformas Flutter
```

---

## 🛠️ Requisitos de Sistema

Para compilar e rodar o projeto localmente, certifique-se de ter instalado:

1. **Flutter SDK** (versão 3.16 ou superior)
2. **Rust & Cargo** (última versão estável)
   Para compilar para iOS, a versão mínima do sistema é **iOS 14**, exigida pelo seletor de arquivos. A abertura e a exportação no macOS usam acesso aos arquivos escolhidos pelo usuário.
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
# 0. Resolver as dependências Flutter
flutter pub get

# 1. Compilar a engine Rust
cargo build --manifest-path rust_core/Cargo.toml

# 2. (Opcional) Gerar bindings FFI se alterar o Rust
# flutter_rust_bridge_codegen generate

# 3. Rodar testes
cargo test --manifest-path rust_core/Cargo.toml
flutter test

# 4. Executar o app no Linux Desktop
env -i HOME="$HOME" PATH="$PATH" DISPLAY="$DISPLAY" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" LD_LIBRARY_PATH="" flutter run -d linux
```

> **Nota:** O comando com `env -i ...` limpa variáveis de ambiente que podem causar conflito com bibliotecas do sistema (comum ao usar Flutter via Snap ou em conjunto com Flatpak).

### Checkpoint do PG II em 10/10/2026

O texto do TCC está em `TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex`. O registro da versão,
os comandos e os resultados da validação estão em [docs/checkpoint/checkpoint-2026-10-10.md](docs/checkpoint/checkpoint-2026-10-10.md).
A sintaxe atual usa `and`, `or` e `not`, aceita ponto e vírgula opcional e recebe uma expressão
por chamada de `print`. O protótipo não possui comando `read` nem anotações de tipo como `x: int`.
O laço `for i in N` percorre os inteiros de zero até `N - 1`.

Os testes automatizados verificam o motor, a ponte FFI e a interface. A avaliação com
estudantes e a validação em smartphones físicos permanecem como etapas posteriores.

### Gerar o APK Android

Use um JDK 17 ou 21 com o Gradle 8.14 deste projeto. Configure o Flutter para usar esse JDK (o `jbr` do Android Studio também serve) e instale os alvos Android do Rust:

```bash
flutter config --jdk-dir="/caminho/do/jdk-21"
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
flutter build apk
```

O SDK Android deve estar configurado em `android/local.properties` (`sdk.dir`) ou em `ANDROID_HOME`/`ANDROID_SDK_ROOT`, com a versão do NDK indicada pelo Flutter instalada. O Gradle compila e inclui a engine Rust para `arm64-v8a`, `armeabi-v7a` e `x86_64` automaticamente. O APK fica em `build/app/outputs/flutter-apk/app-release.apk`.

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

O runtime Dart, a dependência Rust e o gerador `flutter_rust_bridge_codegen` devem usar a mesma versão exata: **2.12.0** neste projeto. Ao atualizar, atualize os três juntos e regenere os bindings antes de compilar. Consulte a [compatibilidade de versões do Flutter Rust Bridge](https://cjycode.com/flutter_rust_bridge/guides/miscellaneous/compatibility).

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

### Atualizar logos e ícones

As logos vetoriais (símbolo e nome, nos temas claro e escuro), os ícones gerados e os dois vídeos de abertura estão em `assets/branding/`. A interface usa os SVGs diretamente. Para regenerar os ícones a partir desses vetores:

```bash
python3 tool/update_branding.py
```

O comando também salva prévias da Home em `build/branding-preview/` e preserva as demais configurações de assets do Xcode.

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
