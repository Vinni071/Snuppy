# Conferência de fontes e comportamentos — Fase 6

Data: 15/11/2026. A principal fonte desta fase é o código do Luminthor e a execução
da revisão `2e33f7e`. As regras abaixo foram separadas da intenção de projeto,
que requer confirmação do autor. Não foram acrescentadas referências bibliográficas.

| Itens | Fonte primária e conferência |
| --- | --- |
| I1 | Implementação local e documentações já registradas de Rust, Flutter, flutter_rust_bridge, Hive, Riverpod e logos. Quadro de alternativas é análise qualitativa retrospectiva; não há comparação empírica de velocidade ou memória |
| I2 | `rust_core/src/lexer/mod.rs` e leitura de literais em `parser/mod.rs`: identificadores ASCII, inteiros/decimais, aspas e preservação de barras, comentários e tokens sem construção sintática correspondente |
| I3, I10 | `interpreter/environment.rs`, avaliação de expressões e chamadas em `interpreter/mod.rs`. Ensaios de tipos, divisão inteira, coerção para texto, ausência de curto-circuito, nulo, recursão e escopo do chamador |
| I4 | `parse_assignment_or_expr`, `parse_call`, `parse_return_stmt` e o Código 1. A demonstração de ambiguidade de `return x` é uma análise da EBNF resumida, não uma alegação de que o algoritmo produz duas árvores. O algoritmo aplica sua própria prioridade de consumo |
| I4, I7 | [Nystrom, capítulo 6](https://craftinginterpreters.com/parsing-expressions.html), já referenciado: ambiguidade, precedência, análise descendente recursiva e sincronização. O registro foi localizado na página do autor e no [repositório do livro](https://github.com/munificent/craftinginterpreters/blob/master/book/parsing-expressions.md) |
| I5, I6 | Programas com quebra de linha, comparações, `not`, `for` e `const` no arquivo de ensaios. Comportamento foi executado; a justificativa original das escolhas não foi inferida |
| I7 | `Parser::synchronize` e `api::process_source`: palavras de sincronização, tentativa de análise após erro léxico e interrupção antes da interpretação. Programa com dois erros sintáticos produziu os dois diagnósticos descritos |
| I8, I12 | `record_step`, `snapshot_all`, `snapshot_by_scope` e cópia do rastro em `InterpreterResult`. Trechos Rust extraídos literalmente. Custo O(PV) assume vínculos/valores de tamanho limitado e não é uma medição de RAM |
| I9 | `semantic/mod.rs`, `const_number`, `check_division_by_zero` e `interpreter/mod.rs`. Literais/constantes e variáveis mutáveis produzem diagnósticos em fases diferentes. Histórico local confirma introdução da checagem estática no commit `7102819` |
| I11 | `find_similar_names`: limiar absoluto 2 e conjunto sem ordenação. O ensaio `var x = 1; print(i);` sugere `x`, sem proteção especial para nomes curtos |
| I12 | JSON do exemplo de cinco linhas: 26 tokens, AST e cinco eventos. A árvore textual mostra rótulos e relações, sem apresentar um desenho como captura de tela |
| I13 | Protocolo proposto e tabelas vazias. Não se atribuem tempos, memória, tamanho ou Android mínimo ao APK sem medição/inspeção do pacote identificado |
| I14 | JSON dos ensaios e `ConsolePanel._buildErrorCard`: o cartão usa `error.message`, enquanto sugestão, posições e tipo são campos separados. Catálogo registra mensagem principal exata, não uma reconstrução de toda a tela |
| I15 | `lib/features/learning/domain/entities/learning_path.dart`: seis módulos e 18 títulos extraídos; conceitos são síntese das explicações/códigos. A progressão depende da pergunta da aula, não de correção automática do programa livre |
| I16 | Logs atuais e LCOV em [evidencias-fase-6](evidencias-fase-6/README.md). Registros de 11/11 e seus quadros numéricos mantidos separados |
| I17 | `WorkspaceNotifier._update` e `core/errors/error_reporter.dart`: `unawaited(...save...)` e `debugPrint` no erro, sem confirmação visível de gravação nesse caminho |
| I18 | Git remoto local com nome antigo `Snupy`; conector GitHub identificou o repositório privado [Vinni071/Snuppy](https://github.com/Vinni071/Snuppy) e confirmou [o commit histórico](https://github.com/Vinni071/Snuppy/commit/47ea64a38162d7b3ff3c22197841d21ae5c30af3). Nenhuma tag de entrega foi presumida |
| I19 | Seção de dificuldades transferida integralmente da conclusão, com rótulo acrescentado no Desenvolvimento |

A [documentação oficial de distribuição Flutter](https://docs.flutter.dev/deployment/android)
foi consultada como complemento à descrição das arquiteturas do Apêndice B. Não foram
substituídas as instruções específicas do projeto por um procedimento atual genérico
do flutter_rust_bridge, cuja documentação pode descrever versões posteriores.

A visão do motor sobre escopos foi explicitamente qualificada: o empilhamento sobre
o ambiente do chamador permite observar seu sombreamento. Comentários de código que
usam “lexical scoping” não foram tratados como prova contra o resultado executado.
A chamada a função aninhada produziu nome não declarado. Esses limites foram
documentados, sem alterar a implementação para obter outro resultado.
