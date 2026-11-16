# Revisão do TCC Luminthor — Fase 6

Data: 15/11/2026. Escopo: desenvolvimento, itens I1–I19. A revisão documental e
a verificação do código disponível foram concluídas. Medições físicas, cobertura
Rust, justificativas originais e identificação da tag permanecem sinalizadas.
A Fase 7 aguarda novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Especificação e exemplos da Lumi](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/especificacao-lumi.tex).
- [Decisões tecnológicas](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/decisoes-tecnologicas.tex).
- [Verificação complementar e protocolo de medições](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/verificacao-complementar.tex).
- [Manuais atualizados](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/manuais.tex).
- [Trecho literal do parser](../../TCC_Teorico/Projeto_LaTeX_TCC/codigos/parser-adicao.rs) e [registro de passo](../../TCC_Teorico/Projeto_LaTeX_TCC/codigos/registro-passo.rs).
- [Diff unificado em relação à Fase 5](revisao-fase-6.patch).
- [Pacote completo dos fontes e evidências](../../output/tcc/Luminthor_Revisao_Fase_6_Fontes.zip).
- [PDF compilado](../../output/pdf/Luminthor_Revisao_Fase_6.pdf).
- [Fontes e alcance das conferências](revisao-fase-6-fontes.md).
- [Logs e reprodução dos ensaios](evidencias-fase-6/README.md).
- [Validação documental](../../output/tcc/Luminthor_Revisao_Fase_6_Validacao.json).

O arquivo principal inclui três novos arquivos de capítulo e dois trechos Rust.
A bibliografia e o pacote institucional permaneceram inalterados. Nenhum fonte do
aplicativo foi modificado. O PDF na pasta do projeto é idêntico ao da entrega.
O ZIP inclui os fontes completos necessários à compilação e as evidências desta
fase; não inclui dependências, builds, APK ou dados pessoais de participantes.

Na pasta `TCC_Teorico/Projeto_LaTeX_TCC`:

```sh
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

Para reproduzir os exemplos, na raiz do repositório com as dependências disponíveis:

```sh
cargo build --offline --manifest-path rust_core/Cargo.toml
python3 docs/tcc/evidencias-fase-6/reproduzir-ensaios.py
```

## 2. Registro de mudanças

| ID | Arquivo/local | Mudança e resultado |
| --- | --- | --- |
| I1 | `decisoes-tecnologicas.tex`, 5.2.4 | Quadro 9 compara Rust/FFI e Dart puro, Flutter e Kotlin, Hive e SQLite/drift, Riverpod e Provider/BLoC, logos e lexer manual. Critérios incluem reuso, memória, integração e desempenho não medido. Explicitado custo de três arquiteturas Android |
| I2 | `especificacao-lumi.tex`, 5.1.4 | Regras de identificadores ASCII, números, textos e barras preservadas, comentários, booleanos/nulo e tokens sem construção sintática implementada |
| I3 | 5.1.5; Quadro 6 e Código 2 | Variantes de Value, operações e conversões, divisão inteira, ausência de curto-circuito, funções e recursão. Ensaio de escopo do chamador qualifica a afirmação de escopo léxico; função aninhada não foi tratada como suportada |
| I4 | 5.1.6 | Explicada leitura de expressão antes da atribuição e reconhecimento de chamada após identificador. Demonstrada ambiguidade de `return x` na EBNF resumida; ela não foi classificada artificialmente como LL(1) ou LL(2). Código 1 preservado |
| I5 | 5.1.6; Quadro 7 | Ensaios de `x = a`/`(b)` e `x = 1`/`-y`: chamada e subtração atravessam a quebra de linha; separador explícito muda o segundo resultado |
| I6 | 5.1.6 | Documentados `for`, `not`, comparação encadeada e `const` sem inicializador. Justificativas e decisão de manter/refinar comportamentos ficaram para o autor |
| I7 | 5.1.7 | Sincronização por palavras iniciais, chave/fim do código, retomada com dois erros e caso de cascata após falha léxica. Não se prometeu eliminação de todos os erros em cascata |
| I8 | `trabalho.tex`, 5.3.11.1 | Análise O(PV) condicionada ao tamanho dos valores, duplicação de mapas e cópia do rastro. Diferenciados eventos e linhas; propostas de diferenças entre estados e orçamentos separados, sem alegar implementação |
| I9 | 5.3.10 e Apêndice A | Alinhadas verificação semântica de divisor constante e verificação em execução de variável mutável. Identificada mudança posterior a `1ff10f8`; não foi atribuída retroativamente ao APK da coleta |
| I10 | 5.1.5 | `var x; print(x + 1);` produz incompatibilidade entre nulo e inteiro na execução. `const x; print(x);` imprime nulo. Esses comportamentos foram executados |
| I11 | 5.1.7 | Limiar absoluto 2 sem exceção para nomes curtos: `i` pode sugerir `x`. Registradas ausência de ordem garantida de candidatos e alternativas de refinamento |
| I12 | 5.1.8; `codigos/*.rs` | Dois trechos Rust literais com listings; exemplo de cinco linhas com 26 tokens, AST e cinco eventos, saída 5 e 3. Árvore textual identificada como síntese do JSON |
| I13 | `verificacao-complementar.tex`, 5.4.3 | Duas tabelas vazias e protocolo para 10/100/1.000 linhas, 100/1.000/10.000 passos, APK, abertura e Android mínimo. Não se inventaram medições; criada Lista de Tabelas |
| I14 | 5.3.10; Quadros 11–12 | Catálogo com categoria, programa e mensagem principal exata extraída dos ensaios. Confirmado no ConsolePanel que mensagem, tipo, sugestão e posição são campos separados |
| I15 | 5.3.7; Quadro 10 | Títulos dos seis módulos e das 18 aulas extraídos de LearningPath; conceitos sintetizados das explicações/códigos |
| I16 | 5.4.1–5.4.2; Quadro 13 | Categorias com casos negativos e nova execução: 68 Rust, 159 Flutter, analyze sem problemas e cobertura de linhas Dart. Cobertura Rust pendente por ausência de cargo llvm-cov; registrado que 65 Rust não cresceram entre outubro e novembro |
| I17 | 5.3.6 | Limitação explícita: falha no salvamento automático só chega ao log nesse caminho; memória atualizada não comprova persistência. Distinguida da gravação aguardada na trilha |
| I18 | 5.4.4 | URL canônica `Vinni071/Snuppy`, privacidade e commit histórico confirmados remotamente; tag não presumida. Acesso da banca e tag de entrega permanecem para informar |
| I19 | `trabalho.tex`, nova 5.5 | Seção de dificuldades movida integralmente da conclusão para Desenvolvimento, com rótulo acrescentado. Demais seções da conclusão renumeradas automaticamente |
| Coerência temporal | 4.2.1–4.2.2 | Matriz e fonte dos marcos distinguem inspeção inicial, revisões históricas não reexecutadas e verificação atual. Logs atuais não substituem logs históricos de novembro |
| Apresentação | Preâmbulo e listas | Linguagem Rust para listings, livro de tabelas sem bordas laterais nas medições e largura de paginação de três dígitos nas listas necessárias. Bloco técnico e resultados numéricos preservados |

### Evidências executadas e limites

O PDF tem **125 páginas**. A compilação terminou sem erros, referências
indefinidas, rótulos duplicados ou caixas excedentes (`Overfull`). Foram renderizadas
e inspecionadas 42 páginas, com ampliação das páginas de código,
aulas e diagnósticos. O documento contém 19 figuras, um gráfico, 18 quadros,
duas tabelas e cinco códigos. A bibliografia conserva 59 entradas, com 58 utilizadas.

Os 68 testes Rust e os 159 Flutter passaram. `flutter analyze --no-pub` informou
“No issues found!”. Os 33 programas via CLI foram reexecutados e seus retornos
comparados ao registro completo. A execução usa Linux x86_64, Flutter 3.47.1,
Dart 3.13.1 e as versões de Rust/Cargo registradas em `ambiente.json`.

A cobertura Flutter é **3.764/4.569 linhas (82,38%) em 71 arquivos presentes no LCOV**.
Excluindo explicitamente os bindings em `lib/src/rust/`, o recorte adicional é
**3.548/3.917 linhas (90,58%) em 63 arquivos**. Não são medidas de ramos, de Rust
ou de execução no aparelho. `cargo llvm-cov` não instalado é uma pendência de
cobertura; não é uma falha dos testes Rust.

Não foram executados benchmarks, novas coletas ou ensaios Android físicos. Os
campos de tempos, memória, APK e abertura continuam vazios. A comparação tecnológica
é qualitativa; a motivação original do autor não foi reconstruída como fato.

### Preservação e numeração

Os cinco quadros numéricos de resultados mantêm conteúdo, fontes e notas
literalmente idênticos. Sete novos quadros alteraram a numeração automática:

| Rótulo | Fase 5 | Fase 6 |
| --- | ---: | ---: |
| `quad:validacao_tecnica` | 7 | 14 |
| `quad:perfil_participantes` | 8 | 15 |
| `quad:respostas_tarefas` | 9 | 16 |
| `quad:usabilidade_participantes` | 10 | 17 |
| `quad:temas_comentarios` | 11 | 18 |

O bloco técnico 5.3.1–5.3.4 e o Código 1 permaneceram literalmente idênticos;
as informações verificadas nesta fase foram acrescentadas ao redor desse bloco.
O corpo da seção de dificuldades foi preservado na transferência. Os dois trechos
Rust conferem com o código do motor. As 14 capturas continuam pendentes.

O diff passou por aplicação simulada contra os fontes preservados da Fase 5.
Os fontes entregues conferem com os usados na compilação. Nenhum fonte de `lib/`,
`rust_core/` ou `test/` foi alterado; logs e ensaios ficam em documentação separada.

## 3. Todos os novos marcadores `\autor{}`

1. `\autor{validar as justificativas das decisões tecnológicas reconstruídas no quadro; informar os critérios originalmente utilizados e eventuais alternativas de fato prototipadas, sem transformar a comparação qualitativa em resultado de desempenho.}`

2. `\autor{justificar as decisões da linguagem: intervalo de zero a N menos um no for, precedência de not, aceitação de comparações encadeadas, const sem inicializador, separadores opcionais e ausência de leitura de entrada e vetores. Confirmar quais comportamentos serão mantidos como decisões e quais serão tratados como limitações.}`

3. `\autor{executar cargo llvm-cov e registrar versão da ferramenta, comandos, escopo, linhas e ramos cobertos no motor Rust; conservar o relatório para permitir conferência. A cobertura Flutter já foi obtida nesta revisão.}`

4. `\autor{realizar e preencher as medições do motor e do APK conforme o protocolo; registrar aparelho, compilação, versões, hash, ferramentas e dados das repetições. Validar os procedimentos propostos antes de executar e não substituir os campos vazios por estimativas de desempenho.}`

5. `\autor{informar a tag de entrega correspondente ao commit 1ff10f8 e a forma de acesso da banca ao repositório privado; confirmar se será disponibilizado um arquivo ou espelho institucional. Não foi criada ou presumida uma tag nesta revisão.}`

Há **5 novos marcadores**. No conjunto, permanecem 14 capturas e
24 outras pendências do autor. As justificativas solicitadas não foram
substituídas por hipóteses do revisor.

## 4. Todos os novos marcadores `\verificar{}`

Nenhum novo marcador nesta fase. Permanecem 12 verificações anteriores.
O alcance da conferência do código, dos registros de execução e das fontes
externas está em `revisao-fase-6-fontes.md`. A visibilidade privada do repositório
foi verificada pelo conector; não foi alterada nem se criou tag remota ou local.

## 5. Questões que bloqueiam a próxima fase

Nenhuma impede iniciar a Fase 7, sobre resultados e discussão, mediante novo
“continue”. Os registros atuais permitem acrescentar a verificação de código
sem modificar os números históricos ou supor qual APK cada participante recebeu.

Para finalizar as evidências de desempenho, continuam necessárias as medições e
os ensaios em aparelhos. Para a Fase 7, os comentários integrais e anonimizáveis
e o procedimento do caso divergente T3 continuam relevantes. A ausência desses
registros deverá permanecer explícita, sem preencher resultados por estimativa.
