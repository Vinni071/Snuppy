# Checkpoint do PG II — Luminthor — 10/10/2026

Este registro acompanha a entrega do checkpoint: texto do PG com procedimentos
metodológicos, ferramentas, descrição das estruturas e dos algoritmos, e código-fonte.
O texto editável está em `TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex`.

## Versão entregue

O pacote contém uma cópia dos arquivos locais, baseada no commit
`7c82b871bb2e5f79358bc0c84cf1d5bc3202170d`, incluindo as alterações ainda não
commitadas dos cabeçalhos de `editor_tab.dart` e `home_screen.dart`.
Também inclui as revisões do TCC, do README e esta documentação. A identificação
dos arquivos efetivamente entregues consta em `SHA256SUMS.txt`, na raiz do pacote.

A integração com IA foi retirada do escopo. O apoio ao estudante utiliza os
diagnósticos determinísticos do motor, executados localmente.

## Implementação disponível

- Editor Lumi com destaque de sintaxe, numeração de linhas, destaque da linha
  selecionada no depurador e atalhos acima do teclado.
- Criação, importação, exportação, salvamento automático e arquivos recentes.
- Motor Rust com lexer, parser recursivo descendente, AST, análise semântica e
  interpretação por caminhada na árvore, integrado ao Flutter por FFI.
- Diagnósticos em português com posições Unicode, contexto e sugestões de nomes.
- Visualizações de tokens, AST, memória, escopos separados e pilha de chamadas.
- Navegação pelo rastro de execução com saída acumulada até o passo selecionado.

A sintaxe implementada utiliza `and`, `or` e `not`, aceita ponto e vírgula
opcional e uma expressão por comando `print`. Declarações e parâmetros não têm
anotações de tipo, e não existe comando `read`. O laço `for i in N` recebe um
inteiro e percorre `0` até `N - 1`; a sintaxe `0..N` não está implementada.

A análise semântica verifica nomes, mutabilidade, escopos, chamadas, quantidade
de argumentos e contexto de comandos de controle. A compatibilidade dos valores
é verificada durante a interpretação. O protótipo não realiza tipagem estática
completa nem análise geral de inicialização definitiva. O campo de avisos da API
permanece vazio no pipeline atual.

## Validação técnica

As dependências e a biblioteca nativa foram preparadas em uma cópia limpa do
código-fonte, sem reaproveitar o diretório de build do projeto. Os testes foram
executados nessa cópia, em Linux, com dependências já disponíveis nos caches locais.

| Suíte | Executados | Aprovados | Falhas |
| --- | ---: | ---: | ---: |
| Motor Rust | 65 | 65 | 0 |
| Flutter, incluindo widgets e FFI real | 58 | 58 | 0 |

Ambiente utilizado: Flutter 3.47.1, Dart 3.13.1, rustc 1.96.0 e Cargo 1.96.0.
As versões completas constam em [ambiente.txt](validacao/ambiente.txt).

Comandos executados na raiz da cópia:

```bash
flutter pub get --offline
cargo build --offline --manifest-path rust_core/Cargo.toml
cargo test --offline --manifest-path rust_core/Cargo.toml
flutter test --no-pub --reporter expanded
```

Em um computador sem as dependências no cache, remova `--offline` dos três
primeiros comandos para permitir o download das dependências. Os bindings Dart/Rust
gerados estão incluídos. Para apenas compilar e testar esta versão, não é necessário
regenerá-los.

Registros completos:

- [Resolução das dependências Flutter](validacao/flutter-pub-get.txt).
- [Compilação da biblioteca Rust](validacao/cargo-build.txt).
- [Testes Rust](validacao/cargo-test.txt).
- [Testes Flutter](validacao/flutter-test.txt).

Os casos incluem posições de erro após caracteres acentuados e no fim do código,
escopos com nomes sombreados, saída acumulada, numeração com quebras visuais,
teclado, temas e dimensões de telas móveis. O teste real de FFI carrega a biblioteca
`rust_core/target/debug/libide_engine.so` criada pelo comando de build.

## Texto do PG

O TCC foi atualizado para apresentar a gramática aceita pelo parser, as estruturas
`TokenInfo`, `Span`, AST, tabelas de símbolos, ambiente, snapshots, passos de execução
e contrato da API. Também descreve tokenização, precedência e recuperação sintática,
análise semântica, distância de Levenshtein, interpretação e navegação pelo rastro.
O registro dos testes foi incluído na metodologia e nas considerações finais.

Para gerar o PDF com TeX Live, os pacotes do modelo institucional e `latexmk`:

```bash
cd TCC_Teorico/Projeto_LaTeX_TCC
latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

O PDF foi compilado e suas páginas foram conferidas visualmente. As listas vazias
de algoritmos e tabelas foram removidas; a gramática continua na lista de códigos,
e os quadros continuam na lista de quadros.

## Etapas posteriores ao checkpoint

A aprovação dos testes automatizados demonstra o atendimento aos casos especificados,
sem medir aprendizagem ou satisfação dos estudantes. A validação em smartphones
físicos, as medições de desempenho móvel e a avaliação com usuários ainda precisam
ser realizadas e registradas. O protocolo de avaliação está descrito no TCC como
planejado, sem apresentar resultados que ainda não foram coletados.

Conforme o cronograma fornecido, a entrega completa para a banca do PG II está
prevista para 14/11/2026. O pacote de 10/10 contém o material do checkpoint;
a submissão ao ambiente da disciplina deve ser feita pelo aluno.
