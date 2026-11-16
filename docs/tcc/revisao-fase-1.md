# Revisão do TCC Luminthor — Fase 1

Data: 15/11/2026. Escopo: itens A e B do roteiro fornecido. Esta entrega encerra
a revisão de credibilidade prevista para a fase, mantendo as verificações ainda
pendentes identificadas no texto. A Fase 2 depende de novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal completo](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Bibliografia atualizada](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib).
- [Fontes completos para substituir o projeto](../../output/tcc/Luminthor_Revisao_Fase_1_Fontes.zip).
- [Diff unificado dos fontes alterados e acrescentados](revisao-fase-1.patch).
- [PDF compilado desta fase](../../output/pdf/Luminthor_Revisao_Fase_1.pdf).

O ZIP contém `trabalho.tex`, `referencias.bib`, o pacote institucional, os manuais
incluídos e os sete novos arquivos vetoriais. O conteúdo de cada `.tex` está
completo. Não é necessário reutilizar as imagens conceituais anteriores para
compilar esta versão. Os arquivos originais de imagem continuam no repositório,
mas não são incluídos pelo texto revisado.

Na pasta do projeto, a compilação é feita com:

```bash
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

O PDF também foi atualizado em `TCC_Teorico/Projeto_LaTeX_TCC/trabalho.pdf`.
Não houve alteração de código do aplicativo nem das respostas da avaliação.

## 2. Registro de mudanças

As localizações por seção usam a estrutura atual de seis capítulos. A
reestruturação em sete capítulos permanece prevista para a Fase 3.

| ID | Arquivo/seção | O que mudou | Situação |
| --- | --- | --- | --- |
| A1 | Introdução; 2.1 e 2.1.3; `.bib` | Retirada a atribuição a Tims de taxas de reprovação introdutória. Acrescentados Bennedsen/Caspersen e Watson/Li; distinguidos aprovação agregada, não aprovação e reprovação em exame | Corrigido; texto integral de 2019 marcado para conferir |
| A2 | Introdução; 2.2.1; Gráfico 1 | Corrigidos denominador e idade; incluídos quatro meios de acesso, estudantes e recortes de rede/nível; gráfico recriado em `pgfplots` | Corrigido com PNAD, p. 10–11 |
| A3 | Introdução e 2.2.1 | Incluídos 230 milhões de computadores e a abrangência da categoria da FGV; retirada a inferência de exclusão a partir da média. Acrescentados rendimentos domiciliares da PNAD | Corrigido; posse por faixa de renda permanece como pendência |
| A4 | 3.1.2 e linha ILDE do quadro comparativo | Removidos plugin Eclipse/VS Code e redução de 35%; descrita a proposta de integração e a avaliação futura do artigo | Corrigido |
| A5 | 2.5.3, 3.2.5, macros e `.bib` | Aplicada a entrada solicitada “Gwendo; Chepkwony”, com nota visível sobre a divergência dos metadados. Mantidos 67,6% como categoria de erros/bugs; corrigida tela para 45,9%, ambos na p. 47; retirados abandono/frustração | Dados corrigidos; forma dos sobrenomes a confirmar |
| A6 | 2.1.2 e 2.4.2; Figura 3; `.bib` | Localizada a sequência na p. 500 do artigo SIGCSE. Reescrita sua interpretação como modelo usado na rubrica; princípios identificados como síntese do autor. Incluído Onward! e discutida sua recomendação contrária a propor soluções | Corrigido |
| A7 | 2.2.3, 3.2.4 e quadro comparativo; `.bib` | Substituída a alegação de melhora significativa por potencial de aprendizagem; corrigidas páginas para 140–143. Retirada a caracterização de exercícios fechados como fato já confirmado | Corrigido; comparação funcional detalhada fica para G |
| A8 | 2.5.2 e 3.2.3 | Pocket Code descrito como inspirado no Scratch; “prova de suficiência” substituída por indicação de viabilidade. Suporte de depuração visual marcado para conferir | Corrigido com pendência explícita |
| A9 | 3.1.1 | Substituída a alegação de superioridade experimental pela descrição de recursos adotados no Portugol Studio | Corrigido |
| A10 | Abertura de 2.1 | Removido “principal fator de reprovação” e usadas fontes que efetivamente estudam resultados introdutórios | Corrigido |
| A11 | 2.1.3 | Removida generalização sobre adoção direta de C ou Java sem levantamento que a sustente | Corrigido |
| A12 | 2.3.2 e 2.4.3 | Lista de tokens reconhecida como especificação própria; retirada a atribuição do Visitante a Aho/Noschang e incluído Gamma et al. | Corrigido |
| A13 | Introdução, 2.3.1 e 2.5.1 | Interpretação por AST referenciada em Nystrom; retirada a suposta suficiência de hardware baseada no Ubi-C; requisitos sem medição convertidos em pendência | Corrigido com pendência de APK/medições |
| A14 | 2.1.2 e `.bib` | Origem das dificuldades referenciada na revisão de Qian/Lehman, sem causa única atribuída a Marceau; quatro exemplos individualizados em uma pendência de conferência de fontes primárias | Referência geral conferida; passagens específicas pendentes |
| B1 | Introdução; Figura 1 | Montagem retirada; criados dois espaços de captura e um par de programas com erro de identificador não declarado | Preparado; duas capturas pendentes |
| B2 | Figura 2 e `figuras/carga-cognitiva.tex` | Removidos percentuais e comparação quantitativa de cargas; criado esquema qualitativo | Concluído |
| B3 | Figura 3 e `figuras/fluxo-resposta-erro.tex` | Redesenhado o esquema com autoria própria, indicação da p. 500 e sem caixa de aplicação ao produto | Concluído |
| B4 | Figura 4 e `figuras/pipeline-luminthor.tex` | Removida AST anotada; representados artefatos reais e retornos anteriores à execução | Concluído |
| B5 | Figura 5 e `figuras/ast-atribuicao.tex` | AST redesenhada em `forest` com `=`, `+` e `*`; removida legenda de cores inconsistente; explicitado seu caráter didático | Concluído |
| B6 | 4.3; Figuras 6 e 7 | Criados diagrama de componentes e diagrama de sequência, conferidos nos contratos e módulos atuais | Concluído |
| B7 | 4.3 e 4.5.6–4.5.10; Figuras 8 a 19 | Acrescentados 12 ambientes com legenda, chamada no texto e pendência de captura | Preparado; 12 capturas pendentes |
| Apoio | Preâmbulo | Definidos os marcadores vermelhos/laranja; preservado o comando de metadados do abnTeX2 sob `\autordotrabalho` antes de reservar `\autor` para pendências | Concluído; capa e folha de rosto conferidas |
| Apoio | Macros e bibliografia | Distintos 2011a/2011b; acrescentadas oito referências. O `.bib` tem 23 entradas, e a bibliografia compilada usa 22; Tims permanece cadastrado, sem uso nesta versão | Concluído |
| Apoio | Comentários do modelo | Retiradas sugestões obsoletas de figuras já substituídas, incluindo sintaxe `:=`, mockups e percentuais de obstáculos sem lastro | Concluído |

### Conferências que alteraram ou qualificaram o roteiro

**Bennedsen e Caspersen (2007).** A fonte distingue `pass`, `fail`, `abort` e
`skip`. O complemento da aprovação agregada de 67% é 33% de não aprovação,
incluindo situações distintas de reprovação no exame. A redação evita tratar
esse complemento como se fosse exclusivamente a categoria `fail`.
[Artigo disponibilizado pelo autor](https://cs.au.dk/~mec/publications/journal/25--bulletin2007.pdf).

**Marceau, Fisler e Krishnamurthi (2011a).** A sequência de leitura, compreensão e
formulação está na p. 500. A correção necessária foi delimitar seu papel na
construção da rubrica, em vez de removê-la por ausência de fonte. O PDF local
`EffectivenessErrorMsg.pdf` foi consultado diretamente; os cinco princípios do
TCC passaram a ser apresentados como síntese própria.

**Gwendo/Chepkwony.** A discussão na p. 47 apresenta 67,6% para erros/bugs e
45,9% para tamanho da tela. A publicação do periódico e seu registro Crossref
apresentam os nomes completos, mas o Crossref organiza os sobrenomes como
“Oloo” e “Robert”. A forma requerida pelo roteiro foi aplicada e sinalizada
com `\verificar` na referência, sem tratá-la como questão resolvida.
[Página do artigo](https://www.ijcaonline.org/archives/volume175/number22/31587-2020920752/),
[metadados do DOI](https://api.crossref.org/works/10.5120/ijca2020920752).

**LogicProg.** As páginas 141–143 do PDF local são imagens e foram lidas por
renderização. O material apresenta conteúdo, acessibilidade e relatos de uso.
Foi retirada a afirmação categórica de que o aplicativo se limita a exercícios
fechados; a comparação detalhada deve ser feita pelo protocolo previsto na Fase 4.
[Publicação identificada pelo DOI](https://doi.org/10.5753/cbie_estendido.2025.13189).

**Qian e Lehman.** O DOI registra publicação eletrônica em 27/10/2017 e
fascículo impresso em 2018. A referência usa 2017 e registra a distinção em
nota. Os metadados indicam páginas 1–24, diferentes das 1–23 informadas na
página pessoal de um dos autores. Foi adotada a paginação do registro editorial.
O resumo confirma a organização geral das dificuldades; as fontes de cada um dos
quatro exemplos continuam marcadas para conferir.
[Metadados editoriais](https://api.crossref.org/works/10.1145/3077618).

### Evidências principais consultadas

| Correção | Fonte consultada e localização |
| --- | --- |
| A1 | Bennedsen/Caspersen (2007), seção 3.1; [Watson/Li (2014)](https://doi.org/10.1145/2591708.2591749), resumo e metadados; [Bennedsen/Caspersen (2019)](https://pure.au.dk/portal/en/publications/failure-rates-in-introductory-programming-12-years-later/), metadados |
| A2/A3 | `pnad-acesso-internet-ibge-16ago2024.pdf`, p. 5 e 10–11; [informativo original do IBGE](https://biblioteca.ibge.gov.br/visualizacao/livros/liv102107_informativo.pdf); [pesquisa FGV 2025](https://eaesp.fgv.br/sites/default/files/legacy/u68/pesti_fgvcia_2025.pdf), seção 7 e resumo de notícias |
| A4 | `IntegratedLearning.pdf`, resumo e plano de avaliação; [DOI do artigo](https://doi.org/10.1109/FIE44824.2020.9273887) |
| A5 | `JohnOloo.pdf`, p. 43 e 47; página do periódico e metadados do DOI indicados acima |
| A6 | `EffectivenessErrorMsg.pdf`, p. 500; [Mind your language](https://cs.brown.edu/people/sk/Publications/Papers/Published/mfk-mind-lang-novice-inter-error-msg/paper.pdf), seção 7; [Becker et al. (2019)](https://doi.org/10.1145/3344429.3372508), seção 8 e metadados |
| A7 | `LogicProg.pdf`, p. 140–143, com inspeção visual das páginas rasterizadas |
| A8 | `PocketCode.pdf`, p. 35–36; [DOI da demonstração](https://doi.org/10.1145/2660252.2664662) |
| A9/A12 | `PortugolStudio.pdf`, seção 4.1; [registro do livro de Gamma et al. na editora](https://www.pearson.com/en-us/subject-catalog/p/design-patterns-elements-of-reusable-object-oriented-software/P200000009480/9780321700698) |
| A13 | [Nystrom, A Map of the Territory](https://craftinginterpreters.com/a-map-of-the-territory.html), seção 2.2.2; fonte do próprio autor |
| B4/B6 | `rust_core/src/api.rs`, contratos `SourceCompiler` e `KeyValueStore`, adaptador de compilação, ViewModel do editor e árvore de funcionalidades em `lib/features` |

Foram confirmados os títulos, autores, anos, veículos, páginas e DOIs aplicáveis
às novas referências de artigos. Livros sem DOI não receberam identificadores
inventados. As datas de acesso novas correspondem a 15/11/2026. A normalização
integral de todas as referências segundo a UTP permanece na Fase 8.

## 3. Pendências do autor desta fase

Há **16 pendências visíveis**: 14 capturas e duas informações de dados/requisitos.
As capturas usam `\capturapendente`, cujo conteúdo é impresso por `\autor` em
vermelho. Assim, não dependem de comentários ocultos no LaTeX para serem localizadas.

1. **Figura 1, lado GCC:** obter a captura real do programa em C proposto, com
   versão do compilador, comando executado e mensagem integral.
2. **Figura 1, lado Luminthor:** obter a captura do mesmo tipo de erro no
   programa Lumi, com versão e hash do APK.
3. **Seção 2.2.1 — A3:** fornecer, se disponível, tabela da PNAD sobre posse de
   microcomputador por faixa de renda, identificando tabela e população. O
   contraste entre rendimentos médios já foi conferido e incorporado.
4. **Seção 2.5.1 — A13:** informar o Android mínimo extraído do APK identificado
   e medições de memória, armazenamento e desempenho. Os requisitos anteriores
   sem evidência não foram mantidos como valores verificados.
5. **Figura 8 — Home:** capturar criação, importação e recentes com dados de
   demonstração e identificação do APK.
6. **Figura 9 — Trilha:** capturar módulos, etapas e progresso da Trilha Lumi.
7. **Figura 10 — Aula:** capturar uma aula com explicação, exemplo e ação de
   prática, informando o título da aula e a versão do APK.
8. **Figura 11 — Editor:** capturar teclado virtual aberto, barra de símbolos e
   numeração, com aparelho, Android e APK identificados.
9. **Figura 12 — Autocompletar:** capturar sugestões junto ao cursor e fornecer
   o programa que determina os símbolos visíveis naquele escopo.
10. **Figura 13 — Erro léxico:** capturar caractere inválido fora de texto ou
    comentário, mantendo código e mensagem exatos.
11. **Figura 14 — Erro sintático:** capturar `print(1;`, com código e mensagem exatos.
12. **Figura 15 — Erro semântico:** declarar `var pontos = 8;` e executar
    `print(pntos);`; capturar diagnóstico e sugestão realmente apresentados.
13. **Figura 16 — Execução:** capturar `var divisor = 0; print(1 / divisor);`,
    com mensagem, rastro disponível e versão identificados.
14. **Figura 17 — Tokens:** capturar tokens de `var x = 0; x = 3 + 5 * 2;`,
    com categorias e posições legíveis.
15. **Figura 18 — AST:** capturar o mesmo programa, expandindo a atribuição e
    seus operadores na árvore exibida pelo aplicativo.
16. **Figura 19 — Depurador:** capturar uma chamada de função com variáveis por
    escopo, pilha, saída e passo selecionado; fornecer também o programa.

Os programas associados às capturas são propostas para produzir evidências.
Não foram apresentados como registros de execução ou como mensagens já capturadas.

## 4. Referências a verificar

São **quatro marcações `\verificar`**, todas visíveis no PDF:

1. **A14 — seção 2.1.2:** consultar o texto integral de Qian/Lehman e as fontes
   primárias de cada exemplo: variável/expressão, atribuição/igualdade, escopo e
   estado inicial; registrar passagens e páginas. A classificação geral foi
   conferida no resumo editorial.
2. **A1 — seção 2.1.3:** obter o texto integral de Bennedsen/Caspersen (2019)
   para conferir a definição do indicador de 28% e a interpretação comparativa.
   Os metadados foram confirmados; o acesso ao texto integral não foi obtido.
3. **A8 — seção 3.2.3:** confirmar depuração visual passo a passo na versão do
   Pocket Code que será comparada. A demonstração de 2014 não confirmou o recurso.
4. **A5 — referência `gwendo2020`:** confirmar a entrada pelos sobrenomes
   Gwendo/Chepkwony solicitada no roteiro, diante da indexação Oloo/Robert no
   registro Crossref. O DOI, a paginação e os percentuais citados foram conferidos.

## 5. Dúvidas que bloqueiam a próxima fase

Não há bloqueio para a Fase 2. As capturas podem ser incorporadas quando
disponíveis, e as quatro verificações permanecem explicitamente sinalizadas.
A decisão sobre os rótulos em inglês será tratada na Fase 2; o aplicativo não
foi traduzido por esta revisão documental.

### Verificação da entrega

- Compilação concluída com `latexmk`, `pdflatex` e BibTeX em cópia isolada dos
  fontes finais, com a bibliografia e os arquivos vetoriais incluídos.
- PDF final com **82 páginas**, sem erros de compilação, citações indefinidas,
  referências internas indefinidas, rótulos duplicados ou avisos de `Overfull`.
- Inspeção visual de 20 páginas selecionadas, incluindo capa, folha de rosto,
  todas as figuras novas/substituídas, gráfico e marcações de pendência. Não se
  trata da certificação normativa integral, prevista para a Fase 8.
- Comparação literal dos atuais Quadros 6 a 10 com a versão de entrada:
  **nenhuma alteração**, inclusive na apresentação nesta fase.
- Comparação literal do bloco das seções 4.5.1 a 4.5.4 com a versão de entrada:
  **nenhuma alteração**.
- Código da aplicação, manuais e respostas da avaliação preservados.
- O arquivo de validação que acompanha o pacote registra hashes, contagens e o
  resultado dessas comparações.

Próxima etapa, após “continue”: **Fase 2 — questão do idioma**, incluindo motivação,
palavras reservadas, rótulos, critérios comparativos e limitações específicas.
