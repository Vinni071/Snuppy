# Revisão do TCC Luminthor — Fase 3

Data: 15/11/2026. Escopo: reestruturação dos capítulos e da introdução, itens
D1–D9 do roteiro. A fase está concluída com duas decisões do autor marcadas no
PDF. A Fase 4 aguarda novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal completo](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Diff unificado em relação à entrega da Fase 2](revisao-fase-3.patch).
- [Pacote completo dos fontes desta fase](../../output/tcc/Luminthor_Revisao_Fase_3_Fontes.zip).
- [PDF compilado](../../output/pdf/Luminthor_Revisao_Fase_3.pdf).
- [Registro de validação e hashes](../../output/tcc/Luminthor_Revisao_Fase_3_Validacao.json).

O único fonte alterado nesta fase é `trabalho.tex`. O ZIP inclui também a
bibliografia, os manuais, o pacote institucional, as sete figuras vetoriais e
este relatório com o diff e a validação. O PDF da pasta do projeto foi atualizado
para a mesma versão da entrega.

Após extrair o ZIP, compilar na pasta `TCC_Teorico/Projeto_LaTeX_TCC`:

```bash
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

## 2. Registro de mudanças

| ID | Arquivo/local | O que mudou |
| --- | --- | --- |
| D1 | `trabalho.tex`, capítulos | Adotada a estrutura: 1 Introdução; 2 Fundamentação Teórica; 3 Trabalhos Relacionados; 4 Metodologia; 5 Desenvolvimento do Luminthor; 6 Resultados e Discussão; 7 Conclusão |
| D2 | Capítulos 2, 4 e 5 | Movidos para o desenvolvimento a especificação da Lumi, o Código 1, a lista de tokens, o fluxo implementado e as decisões sobre AST, símbolos, percursos e sugestões. Separadas a implementação e a avaliação com participantes |
| D3 | Antigo Quadro 3 | Removido o resumo redundante de gramática e sua chamada. O Código 1 conserva o inicializador opcional e permanece idêntico à Fase 2 |
| D4 | Introdução, 1.1–1.6 | Definido “nativo” na primeira ocorrência no corpo da introdução; apresentados justificativa, escopo, síntese do método e contribuições concretizadas. Retirados os quantitativos da amostra da síntese do método e atualizado o roteiro dos capítulos |
| D5 | Introdução, 1.2 | Mantido o autocompletar no objetivo a; acrescentados objetivos próprios para Trilha Lumi e gestão de arquivos. Objetivo f usa a avaliação exploratória disponível, com duas alternativas apresentadas para decisão do autor |
| D6 | Texto e remissões | Eliminadas as expressões “projeto proposto”, “compilador proposto”, “sistema proposto” e “contribuições esperadas”. Atualizada a resposta à pergunta de pesquisa na conclusão, sem refazer sua revisão prevista para a Fase 8 |
| D7 | Antigas 4.3 e 4.4; novas 5.1 e 5.2 | Eliminada a organização com subseção única. Linguagem Lumi tem princípios, idioma e especificação; arquitetura tem componentes, organização por funcionalidade e requisitos de execução |
| D8 | Abertura do Capítulo 2 e síntese 2.6 | Retirada a promessa de seis eixos. A abertura descreve os assuntos efetivamente presentes; a síntese teórica remete a comparação e implementação aos capítulos correspondentes. Título de 2.1 simplificado para “Aprendizagem Inicial de Programação” |
| D9 | Nota de revisão ao fim da introdução | Inseridas três alternativas de título e pendência de escolha; mantido o título atual nos metadados, na capa e na folha de rosto |
| Coerência estrutural | Capítulos 2 e 3 | Comparações das ferramentas concentradas no Capítulo 3. Evidência de Gwendo/Chepkwony deslocada para 3.2.5, preservando a distinção dos percentuais e seu contexto; descrição duplicada do LogicProg consolidada no capítulo de relacionados |
| Apresentação | Sumário | Atualizadas numeração, destinos e páginas. Ampliado localmente o espaço reservado à direita para separar títulos longos dos números de página |

### Mapa dos principais deslocamentos

As origens abaixo correspondem à versão da Fase 2. As numerações de destino
foram conferidas no sumário e nos rótulos gerados pelo LaTeX.

| Origem | Destino nesta fase |
| --- | --- |
| 2.3.1, fluxo real de análise e interpretação | Abertura de 5.3, Implementação do Protótipo |
| 2.3.2, tokens específicos da Lumi | 5.1.3, Especificação Léxica e Sintática |
| 2.3.3, descrição da Lumi, EBNF e escolha do parser | 5.1.3; Código 1, p. 44 |
| 2.3.4, atribuições e contexto dos diagnósticos | 5.3.5, Representações e Percursos de Análise |
| 2.3.5, tabela de símbolos da implementação | 5.3.5 |
| 2.4.2, regras determinísticas de sugestão | 5.3.10, Diagnósticos e Mensagens Formativas |
| 2.4.3, discussão de idioma da Fase 2 | 5.1.2, mantendo o rótulo `sec:idioma_lumi` e suas remissões |
| 2.4.4, implementação de percursos por `match` | 5.3.5; conceito geral de Visitante permanece em 2.4.3 |
| 2.5.1, requisitos e escolhas da plataforma do artefato | 5.2.3, com a pendência de medições preservada |
| 2.5.3, evidência empírica de uso móvel | 3.2.5 |
| 2.6, comparação do antigo Quadro 1 | 3.3, junto ao Quadro 2; consolidação em quadro único fica para a Fase 4 |
| 4.3, arquitetura | 5.2 |
| 4.4, princípios da linguagem | 5.1.1 |
| 4.5.1–4.5.4, tecnologias, pipeline, estruturas e algoritmos | 5.3.1–5.3.4, integralmente preservadas |
| 4.5.5–4.5.10, arquivos, trilha, editor, autocompletar, diagnósticos e depurador | 5.3.6–5.3.11 |
| 4.6, testes e validação técnica | 5.4 |
| 4.7, avaliação com participantes | 4.3, permanecendo na metodologia |
| Capítulos 5 e 6 | Capítulos 6 e 7 |

### Escopo conferido no repositório

A ausência de leitura de entrada e de vetores foi conferida em
`rust_core/src/lexer/mod.rs`, `rust_core/src/parser/mod.rs`,
`rust_core/src/ast/mod.rs`, `rust_core/src/interpreter/mod.rs` e
`rust_core/src/interpreter/environment.rs`. A AST e os valores da linguagem não
oferecem vetores, literais de listas ou acesso por índice. As coleções Rust usadas
internamente pelo motor não constituem suporte a vetores nos programas Lumi.
Por haver código suficiente para essa conferência, não foi criada uma pendência
de confirmação do autor para esse ponto de D4.

Android foi explicitado como plataforma do artefato documentado. “Nativo” ficou
definido como o motor Rust compilado para o processador do aparelho e integrado à
interface Flutter. Isso foi distinguido da interpretação dos programas Lumi, que
não produz código de máquina para cada programa do estudante.

### Preservação dos dados e renumeração dos quadros

Os ambientes completos dos antigos Quadros 6–10 foram comparados literalmente
com a versão da Fase 2. Conteúdo, valores, categorias e fontes são idênticos.
A remoção do quadro redundante altera os números das legendas automaticamente:

| Quadro na Fase 2 | Quadro nesta fase | Conteúdo preservado |
| --- | --- | --- |
| 6 | 5 | Resultados dos testes automatizados |
| 7 | 6 | Perfil dos participantes |
| 8 | 7 | Registros das tarefas |
| 9 | 8 | Respostas de usabilidade |
| 10 | 9 | Temas dos comentários |

O quadro de tarefas do formulário, antes numerado como 5, passou a 3 por estar
na metodologia. O quadro de diagnósticos permanece como 4. Os dois quadros de
comparação continuam como 1 e 2, agora ambos no Capítulo 3.

### Verificação da entrega

- PDF com 87 páginas, compilado em cópia isolada dos fontes.
- Nenhum erro de compilação, referência indefinida, rótulo duplicado ou caixa
  excedendo as margens no log final.
- Inspeção visual de 30 páginas, com sumário, introdução, decisões do autor,
  aberturas dos capítulos, gramática, quadros, diagramas e remissões do manual.
- Código 1 e bloco das antigas seções 4.5.1–4.5.4 idênticos à Fase 2.
- Mantidos 19 figuras, um gráfico e um código; nove quadros após a remoção de D3.
- Bibliografia e manuais sem alteração de fonte: 26 referências cadastradas e
  25 utilizadas. Nenhuma referência foi acrescentada nesta fase.
- Dois novos marcadores `\autor`; nenhum novo `\verificar`. Total atual:
  14 capturas e cinco outras pendências do autor, além de oito verificações.
- Código do aplicativo e dados da avaliação sem alteração. Não foram executados
  novos ensaios de uso nem testes do aplicativo nesta revisão documental.

A ampliação da teoria e dos trabalhos relacionados permanece na Fase 4. O
enquadramento metodológico, a ética e os instrumentos serão trabalhados na Fase 5;
a conferência técnica ampliada, na Fase 6; a revisão dos resultados, na Fase 7;
e a conclusão, o resumo e as normas completas, na Fase 8.

## 3. Marcadores `\autor` inseridos nesta fase

1. **1.2, objetivo f:** “definir se haverá nova coleta com iniciantes para o
   objetivo f; a redação atual corresponde à avaliação exploratória disponível.
   As duas alternativas abaixo ficam para decisão do autor.” No PDF estão as
   redações para avaliação percebida sem nova coleta e para sessões observadas
   com iniciantes, condicionadas à realização dessa etapa.
2. **Nota de revisão ao fim da introdução:** “escolher título. O título atual
   foi mantido na capa e na folha de rosto; as alternativas abaixo descrevem o
   artefato implementado.” Alternativas apresentadas:

   - Luminthor: ambiente móvel com interpretador didático local para o ensino de lógica de programação.
   - Desenvolvimento do Luminthor: ambiente Android com linguagem didática e visualização da execução de programas.
   - Luminthor: ambiente Android para edição, análise e interpretação local de programas didáticos.

## 4. Marcadores `\verificar` inseridos nesta fase

Nenhum. Os oito marcadores preexistentes foram preservados, com deslocamentos
acompanhando seus conteúdos. Em particular, os três relativos à aplicação da
literatura de idioma estão em 5.1.2, e o marcador dos critérios comparativos está
em 3.3. As pendências não foram tratadas como resolvidas pela reorganização.

## 5. Perguntas que impedem a próxima fase

Nenhuma decisão impede iniciar a Fase 4 com “continue”. Permanecem para o autor
a escolha do título, a decisão sobre nova coleta e a tradução ou justificativa
dos rótulos da interface registrada na fase anterior. Até haver decisão, o título
atual e o objetivo compatível com a avaliação disponível foram mantidos.
