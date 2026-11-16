# Revisão do TCC Luminthor — Fase 4

Data: 15/11/2026. Escopo: fundamentação teórica e trabalhos relacionados,
itens F e G. A fase está concluída com as verificações e os ensaios ainda
dependentes do autor identificados no PDF. A Fase 5 aguarda novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal completo](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Bibliografia completa](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib).
- [Diff unificado em relação à Fase 3](revisao-fase-4.patch).
- [Pacote completo dos fontes](../../output/tcc/Luminthor_Revisao_Fase_4_Fontes.zip).
- [PDF compilado](../../output/pdf/Luminthor_Revisao_Fase_4.pdf).
- [Conferência das novas fontes](revisao-fase-4-fontes.md).
- [Registro de validação](../../output/tcc/Luminthor_Revisao_Fase_4_Validacao.json).

Foram alterados `trabalho.tex` e `referencias.bib`. O ZIP contém os fontes
completos, os manuais, o pacote institucional, as sete figuras vetoriais e os
relatórios, diff e validação desta fase. O PDF da pasta do projeto foi atualizado
para a mesma versão da entrega.

Compilar na pasta `TCC_Teorico/Projeto_LaTeX_TCC`:

```bash
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

## 2. Registro de mudanças

| ID | Arquivo/local | O que mudou | Situação |
| --- | --- | --- | --- |
| F1 | `trabalho.tex`, 2.4.1–2.4.3; `.bib` | Acrescentados Denny/Luxton-Reilly/Carpenter (2014) e Becker (2016), com resultados distintos e contextos delimitados; articulados ao levantamento de Becker et al. (2019) e aos dois Marceau (2011). Princípios mantidos como síntese do autor | Concluído |
| F2 | 2.6; introdução, contribuições; discussão | Criada fundamentação de máquina nocional, teste de mesa e envolvimento do aprendiz, com Sorva (2013), Sorva/Karavirta/Malmi (2013) e Guo (2013). Depurador identificado como recurso central da contribuição didática pretendida | Concluído |
| F3 | 5.1.2 | Preservada a discussão de idioma da Fase 2, com Guo (2018), Dasgupta/Hill (2017) e Hermans (2020), inclusive os marcadores solicitados | Mantido |
| F4 | 2.1.2; `.bib` | Conferidas atribuição e inicialização no catálogo de Sorva (2012), p. 359–360, e comparação/escopo em Qian/Lehman (2017), seções 3.2–3.3. Retirada a antiga pendência A14 | Concluído |
| F5 | Nova 2.7; método da avaliação; `.bib` | Apresentados ISO 9241-11:2018, Nielsen (1993), SUS de Brooke (1996) e modelo de descoberta de problemas de Nielsen/Landauer (1993). Separados questionário próprio, SUS, percepção e observação | Concluído; paginação/identificador da edição de Brooke a conferir |
| F6 | 2.3 e 2.4 | Acrescentados LL(k), antecipação, ambiguidade, recuperação em modo pânico, AST versus bytecode e semelhança entre nomes. Citados Aho, Nystrom, Levenshtein e Gamma; cadastrados Louden e Cooper/Torczon | Conteúdo ampliado; consulta dos volumes de Louden/Cooper marcada |
| F7 | 2.5; arquitetura no Capítulo 5; `.bib` | Fundamentadas compilação móvel, Rust, FFI, geração de ligações, Logos, MVVM, Riverpod e Hive com documentação e acesso datado. Distintas as versões documentais e as resolvidas no projeto | Concluído |
| F8 | 2.5.3; `.bib` | Incluído TouchDevelop, de Tillmann et al. (2011), como referência de interação e edição por toque | Concluído |
| F9 | 2.1.1; `.bib` | Incluídos exemplos resolvidos e sequenciamento, com Sweller/Cooper (1985), preservando o contexto de álgebra do estudo e distinguindo a aplicação à programação | Concluído |
| F, ajustes | Capítulos 2 e 3 | Mantida a pendência de requisitos reais do APK em 5.2.3; tratada a lacuna como tecnológica e delimitada; corrigida a distinção token/lexema | Concluído no escopo documental |
| G1 | 3.2–3.3; `.bib` | Acrescentados Portugol Mobile, WebStudio, VisuAlg, Python Tutor, Thonny, Pydroid 3 e Sololearn | Concluído com classificações documentais |
| G2 | 3.3, comparação móvel | Preparado ensaio comum de laço, função e erros, distinguindo carregamento inicial, execução e uso sem rede; criada pendência de aparelho, versões e capturas | Pendente do autor; nenhum teste no celular foi inventado |
| G3 | Nova 3.1 | Descrita a seleção dirigida efetivamente feita e proposto protocolo complementar com bases, termos, período, inclusão/exclusão e registro | Proposta pronta; histórico ou aprovação do autor pendente |
| G4 | 3.4; quadro único | Substituídos os dois quadros por um único quadro de 14 ferramentas e nove critérios, com legenda S/N/NC/NA. Definidos localidade, memória, exposição de tokens/AST e trilha | Concluído com células não confirmadas explícitas |
| G5–G6 | Síntese comparativa; caracterização do problema | Retiradas a alegação “nenhum trabalho existente integra” e a inferência de exclusividade. Reconhecidos recursos já documentados em Mobile, WebStudio, Python Tutor e Thonny | Concluído; diferenciais após ensaios ficam para confirmar |

### Conferências que qualificam o roteiro

O artigo do WebStudio tem **três autores**: Douglas Gadelha Souza Silva,
Danilo Gadelha Souza Silva e Márcio Renê Brandão Soussa. O PDF apresenta os dois
primeiros em ordem diferente da página do periódico e do Crossref; a bibliografia
segue estes últimos, com nota visível para confirmar a ordem. A transpilação e a
execução no navegador estão na p. 19 do artigo. A documentação atual do repositório
foi distinguida da versão descrita em 2022.

O README do Portugol Mobile documenta execução passo a passo, mas mantém inspeção
de variáveis no roteiro de desenvolvimento. Esse registro foi tratado como
documentação a confrontar com a versão do aplicativo, sem provar ausência atual.
No Thonny, a documentação já descreve revisão de estados de execução. Esses achados
impedem tratar navegação pelo rastro como novidade exclusiva do Luminthor.

A bibliografia passou de 26 para **54 entradas cadastradas e 53 utilizadas**.
São 28 entradas novas, incluindo 11 fontes separadas de documentação e catálogos
de software. A cobertura dessas fontes exigidas ultrapassa a meta indicativa de
30–40 entradas; elas não foram reunidas em referências artificiais. Tims permanece
cadastrado e sem uso. A terceira edição do livro de Rust, publicada em 2026,
inclui Chris Krycho além de Klabnik e Nichols.

### Critérios e preservação

O quadro compara documentação, não resultados de um ensaio controlado. “S”
significa recurso documentado; “NC”, informação não confirmada. Existência de
AST interna não foi contada como exposição da AST ao usuário. Execução no
navegador foi separada de funcionamento sem conexão. O suporte móvel “parcial”
do Portugol Studio foi substituído por sua plataforma documentada, desktop.

O idioma dos diagnósticos do Ubi-C ficou **NC**. Foram retiradas a mistura com
qualidade pedagógica e as afirmações não conferidas de ausência total de
localização. Seus recursos específicos de depuração e inspeção também exigem
fonte ou versão verificável. O quadro não usa lacunas documentais como prova
de exclusividade.

Os cinco quadros de resultados e o bloco técnico das antigas seções 4.5.1–4.5.4
foram preservados literalmente. A consolidação de dois quadros em um provoca
renumeração das legendas:

| Quadro na Fase 3 | Nesta fase | Conteúdo |
| --- | --- | --- |
| 5 | 4 | Testes automatizados |
| 6 | 5 | Perfil dos participantes |
| 7 | 6 | Registros das tarefas |
| 8 | 7 | Usabilidade |
| 9 | 8 | Temas dos comentários |

### Validação

- PDF com 100 páginas, compilado a partir de cópia isolada dos fontes.
- Sem erros, referências indefinidas, rótulos duplicados ou texto excedendo
  as margens no log final; sumário e listas regenerados.
- Inspeção visual de 40 páginas, incluindo teoria, fontes, quadro único,
  decisões pendentes, resultados e remissões do manual.
- Mantidos 19 figuras, um gráfico e o Código 1. O documento tem oito quadros.
- Código do aplicativo, manuais, figuras e dados da avaliação sem alteração.
- Três novos marcadores `\autor` e cinco novos `\verificar`. A14 foi resolvido;
  a nota dos dois quadros antigos foi substituída pela verificação do quadro único.
- Total atual: 14 capturas e oito outras pendências do autor; onze verificações.

## 3. Marcadores `\autor` inseridos nesta fase

1. **3.1, protocolo:** informar o procedimento original ou aprovar o protocolo
   complementar; executar e registrar as consultas antes de descrevê-las como
   concluídas. As bases propostas não são apresentadas como histórico real.
2. **3.3, comparação direta:** instalar e testar Portugol Mobile e WebStudio no
   celular, registrando versões, aparelho, capturas, execução sem conexão,
   depuração, mensagens em português e inspeção de memória.
3. **3.4, diferenciais:** confirmar os diferenciais após os testes, especialmente
   estados por escopo, exposição de tokens/AST e integração da trilha. Células NC
   não devem fundamentar uma afirmação de ausência ou originalidade.

## 4. Marcadores `\verificar` inseridos nesta fase

1. **F6, 2.3.3:** conferir os trechos e a edição usada de Louden (2004) e
   Cooper/Torczon (2012). Metadados localizados; volumes integrais não consultados.
   A descrição técnica foi apoiada em Aho e Nystrom.
2. **G4, 3.4:** conferir por versão as células NC, sobretudo idioma dos
   diagnósticos, depuração e inspeção de estado das ferramentas móveis.
3. **G1, referência do WebStudio:** confirmar a ordem dos dois autores Silva,
   divergente entre PDF e metadados do periódico/Crossref. Os três nomes estão
   conferidos.
4. **F5, referência de Brooke:** conferir paginação e identificador do capítulo
   na edição utilizada. O manuscrito da SUS foi consultado; a página da editora
   não ficou acessível. Não foram preenchidos páginas ou DOI sem essa conferência.
5. **F6, referência de Levenshtein:** confirmar a paginação completa da tradução
   inglesa. O texto indexado da p. 707 foi conferido; o arquivo integral não ficou
   acessível para a conferência do intervalo completo.

## 5. Perguntas que impedem a próxima fase

Nenhuma pendência impede iniciar a Fase 5 com “continue”. Os ensaios comparativos,
o protocolo original ou complementar e as verificações bibliográficas continuam
necessários para fechar as evidências indicadas. As decisões anteriores sobre
título, nova coleta e rótulos permanecem abertas.
