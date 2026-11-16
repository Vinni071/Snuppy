# Revisão do TCC Luminthor — Fase 0

Data: 15/11/2026. Documento de diagnóstico, sem alterações na monografia.

## 1. Arquivos LaTeX alterados

Nenhum. Conforme a Fase 0 do roteiro fornecido, foram preservados `trabalho.tex`,
`apendices/manuais.tex`, `referencias.bib`, `packages/abnt-UTP.sty`, as imagens e o
PDF existente. Não há diff de texto acadêmico nesta entrega. O único arquivo
acrescentado é este relatório.

Foram lidos o arquivo principal completo, os dois manuais incluídos, a bibliografia
e o pacote institucional. O PDF existente tem 77 páginas. Foram examinadas
visualmente as sete imagens efetivamente incluídas e páginas selecionadas do PDF.
Os exemplos do modelo que permanecem comentados no final de `trabalho.tex` não
integram o texto publicado e não foram classificados como capítulos ausentes.

O manual **Normas técnicas: elaboração e apresentação de trabalhos
acadêmico-científicos**, 4. ed., Curitiba: UTP, 2024, foi obtido no endereço oficial
indicado pelo README e lido integralmente por extração de texto, com inspeção
visual de exemplos de formatação. São 151 páginas físicas no arquivo, incluindo
material preliminar; a ficha catalográfica informa 150 páginas. Fonte:
[manual oficial da UTP](https://tuiuti.edu.br/wp-content/uploads/2024/09/e-book_NT_UTP_2024-1.pdf).

Também foram consultados os registros de avaliação, o resumo agregado em JSON,
o checkpoint de outubro, o histórico Git e pontos específicos do código Rust,
Flutter e Android. Essa inspeção inicial permite planejar a conferência técnica;
não equivale à execução dos ensaios previstos para as fases posteriores.

### Situação encontrada

| Elemento | Estado atual | Implicação para a revisão |
| --- | --- | --- |
| Estrutura | Seis capítulos: introdução, fundamentação, relacionados, metodologia, resultados e conclusão | Criar o capítulo de desenvolvimento e renumerar resultados e conclusão |
| Bibliografia | 15 entradas no `.bib` | Auditar as existentes e ampliar segundo a pertinência das novas seções |
| Citações | Macros com autoria e ano escritos manualmente; bibliografia carregada por `\nocite` | Revisar também as macros; alterar apenas o `.bib` não corrige as citações no corpo |
| Ilustrações | Seis figuras e um gráfico, todos com imagens rasterizadas | Substituir esquemas por vetores e reservar capturas para telas realmente observadas |
| Quadros e tabelas | Dez quadros e nenhum ambiente `table` ativo | Transformar os atuais Quadros 6 a 9 em tabelas; preservar os dados e o Quadro 10 |
| Capturas do aplicativo | Nenhuma das sete imagens incluídas é uma captura comprobatória do aplicativo em uso | Preparar espaços identificados para as capturas reais |
| Pré-textuais | Há resumo em português, listas, siglas e símbolos; não há Abstract nem folha de aprovação inseridos | Completar na Fase 8 |
| Apêndices | A: manual do usuário; B: manual técnico | Manter e acrescentar formulário aplicado e consentimento como C e D |
| Metodologia | Pesquisa ainda descrita como experimental; implementação misturada ao método | Reclassificar e separar construção do artefato, avaliação e evidências |
| Ética e validade | Limites discutidos em vários locais; não há seção própria de ética nem ameaças organizadas | Criar ambas sem inferir aprovação ou enquadramento institucional |

### Cuidados técnicos identificados

1. **Conflito do comando `\autor`.** O abnTeX2 já o utiliza para cadastrar o nome
   do autor, na linha 21. Copiar literalmente `\newcommand{\autor}` causa conflito.
   Na Fase 1, preservar o comando de metadados com outro nome, manter o cadastro
   de Vinicius Rodrigues da Costa e redefinir `\autor` como marcador de pendências.
   Conferir capa e folha de rosto após a alteração. A semântica e as cores pedidas
   para `[AUTOR: ...]` e `[VERIFICAR: ...]` serão mantidas.
2. **Versões diferentes do produto.** O texto atribui os resultados de 11/11 ao
   commit `1ff10f8`; a revisão atual é `95d3cddc9b792700a2bdd7b2a9d12db22f9211c0`.
   O commit `80e7081`, de 12/11, acrescentou detecção semântica de divisor
   comprovadamente zero e o campo `const_value` na estrutura de símbolos. Portanto,
   a descrição da versão atual, os testes históricos e o APK recebido pelos
   participantes precisam ter identificações distintas. A discrepância de I9 não
   deve ser resolvida apenas escolhendo uma das duas descrições existentes.
3. **Divisão por zero no código atual.** A inspeção encontrou verificações
   semânticas para expressões numéricas determináveis antes da execução e
   verificações no interpretador. Isso não demonstra que os APKs da coleta já
   continham ambas. Os casos e as mensagens ainda precisam ser reproduzidos na
   versão que será documentada.
4. **Atribuição e chamada.** O parser atual lê uma expressão e, se o resultado
   for identificador seguido de operador de atribuição, constrói a atribuição.
   Chamadas são reconhecidas em outro procedimento. Não se deve classificá-lo
   como LL(1) ou LL(2) apenas pelo prefixo das produções do Código 1; será necessário
   distinguir a gramática escrita do algoritmo implementado.
5. **Vetores.** Há tokens para colchetes, mas não foi encontrada variante de vetor
   em `Value` ou nas expressões da AST examinadas. Reconhecimento léxico de um
   delimitador não comprova implementação da construção. Conferir parser e
   execução antes de fechar a delimitação do escopo.
6. **Rótulos em inglês.** `Execute`, `Trace` e `Settings` estão no editor atual;
   `Templates` está na navegação da Home. São rótulos observados no código, não
   somente nomes internos de classes. A documentação não poderá apresentá-los
   como traduzidos antes da decisão e da correspondente mudança no produto.
7. **Instrumentos diferentes.** `formulario-participante.md` tem 13 questões.
   O texto e o registro de resultados descrevem um instrumento aplicado com 20.
   O primeiro não pode ser apresentado como reprodução integral do segundo.
8. **Dados originais ausentes.** O README dos resultados informa que a exportação
   original permanece com o pesquisador. O JSON local contém agregados e o hash
   da fonte, mas não traz as transcrições integrais de comentários nem todos os
   enunciados e textos de consentimento aplicados.
9. **Revisões antigas.** A análise de 28/10 e o roteiro anterior de finalização
   registram versões anteriores do trabalho. Por exemplo, a afirmação antiga de
   que não há capítulo de resultados já não corresponde ao arquivo atual.
10. **Paginação.** No PDF atual, a página física 15 corresponde à página impressa
    14. As localizações deste relatório usam prioritariamente linhas e rótulos do
    LaTeX, evitando a ambiguidade entre página física e número impresso.

## 2. Registro de mudanças e mapa de reestruturação

### Registro desta entrega

| ID | Arquivo/seção | O que mudou |
| --- | --- | --- |
| F0-01 | `docs/tcc/revisao-fase-0.md` | Criado diagnóstico, mapa de estrutura, inventário de evidências e pendências |
| F0-02 | Fontes LaTeX, `.bib`, estilo, imagens e PDF | Nenhuma alteração; preservados como base da revisão |

### Estrutura atual → estrutura prevista

Os números e as linhas de origem correspondem à versão lida nesta fase. Os
subtítulos de destino são uma organização de trabalho; a numeração definitiva
será gerada pelo LaTeX na Fase 3.

| Origem atual | Localização em `trabalho.tex` | Destino previsto | Operação |
| --- | --- | --- | --- |
| Pré-textuais | 1–181 | Pré-textuais | Preservar identificação; acrescentar Abstract e folha de aprovação; revisar listas |
| 1 Introdução | 188–300 | 1 Introdução | Corrigir motivação e fontes; explicitar justificativa, escopo, definição de nativo e contribuições; ajustar objetivos e roteiro |
| 2.1 Aprendizagem inicial | 316–402 | 2 Fundamentação teórica | Rever reprovação, carga cognitiva e concepções equivocadas; fundamentar exemplos resolvidos |
| 2.2 Acesso e aprendizagem móvel | 408–481 | 2 Fundamentação teórica | Corrigir população de referência da PNAD e argumento socioeconômico; levar a análise do LogicProg ao capítulo 3 |
| 2.3 Compiladores | 487–724 | 2 Fundamentação teórica | Manter conceitos gerais de léxico, gramáticas, AST e análise semântica; acrescentar fundamentos de interpretação e recuperação |
| Tokens específicos da Lumi em 2.3.2 | 548–557 | 5.1 Linguagem Lumi | Separar especificação própria da teoria; remover atribuição a Noschang |
| EBNF, Código 1 e escolhas concretas de 2.3.3 | 576–638 | 5.1 Linguagem Lumi | Unificar a especificação e explicar precedência, separadores e decisões do parser |
| Fluxo real do Luminthor em 2.3.1 | 503–527 | 5.3 Motor de análise e interpretação | Usar o fluxo implementado; a teoria continua no capítulo 2 |
| Trechos de implementação de 2.3.4 e 2.3.5 | 688–716 | 5.3 Motor de análise e interpretação | Mover descrição de atribuições, tabelas de símbolos e limites da análise estática |
| 2.4 Tratamento de erros | 730–789 | 2 Fundamentação teórica | Reescrever princípios como síntese do autor; discutir evidências contrárias, idioma e limites das sugestões |
| Implementação por `match` em 2.4.3 | 766–779 | 5.3 Motor de análise e interpretação | Manter no capítulo 2 o conceito de Visitante e sua fonte apropriada |
| 2.5 Execução móvel | 795–862 | 2 Fundamentação teórica e 3 Trabalhos relacionados | Separar tecnologias, ergonomia e trabalhos empíricos; retirar requisitos de hardware sem medição |
| 2.6 Síntese e Quadro 1 | 867–926 | Final do capítulo 2 e comparação no capítulo 3 | Manter síntese teórica; reformular lacuna tecnológica; eliminar duplicação comparativa |
| Seções novas de visualização e usabilidade | Ausentes | 2.6 Visualização de programas e 2.7 Avaliação de usabilidade | Fundamentar depurador, máquina nocional, teste de mesa e desenho da avaliação |
| 3 Trabalhos relacionados | 931–1113 | 3 Trabalhos relacionados | Acrescentar ambientes previstos em G1, protocolo de busca e quadro comparativo único |
| 4.1 e 4.2 | 1130–1185 | 4 Metodologia | Reclassificar pesquisa; detalhar etapas, iterações, requisitos e método de avaliação |
| 4.3 Arquitetura | 1191–1263 | 5.2 Arquitetura do Luminthor | Incorporar a subseção única ao nível superior; diagramas de componentes e sequência |
| 4.4 Linguagem | 1269–1318 | 5.1 Linguagem Lumi | Incorporar princípios, EBNF e especificação léxica; remover o Quadro 3 redundante |
| 4.5.1 a 4.5.4 | 1326–1468 | 5.2 e 5.3 Desenvolvimento | Preservar conteúdo técnico sobre tecnologias, pipeline, estruturas e algoritmos, com ajustes pontuais documentados |
| 4.5.5 a 4.5.10 | 1470–1662 | 5.4 Aplicativo e recursos didáticos | Organizar arquivos, trilha, editor, autocompletar, diagnósticos e depurador; incluir capturas e quadros técnicos |
| 4.6 Estratégia de testes | 1668–1702 | 5.5 Testes | Detalhar categorias, casos negativos e rastreabilidade; resultados efetivos ficam no capítulo 6 |
| 4.7 Avaliação com participantes | 1704–1774 | 4 Metodologia | Preservar descrição da coleta; completar recrutamento, instrumento, análise e ética |
| 5 Resultados e discussão | 1781–2073 | 6 Resultados e discussão | Preservar dados; converter quadros estatísticos; discutir iniciantes, literatura e limites |
| Limitações hoje dispersas | Resumo e diversos capítulos | Resumo, seção de ameaças à validade e conclusão | Concentrar as ressalvas gerais nos três locais pedidos; preservar informações metodológicas necessárias |
| 6.1 Dificuldades de implementação | 2099–2123 | 5.6 Dificuldades e limitações técnicas | Retirar da conclusão e associar às decisões documentadas |
| 6 Conclusão | 2079–2167 | 7 Conclusão | Avaliar objetivos em quadro, responder à pergunta, enunciar contribuições e organizar trabalhos futuros |
| Referências e apêndices A/B | 2969–2972 e `apendices/manuais.tex` | Pós-textuais | Corrigir bibliografia e tipografia; manter manuais; acrescentar apêndices C/D |

A fundamentação terá conceitos gerais; o desenvolvimento documentará as escolhas e
o comportamento da Lumi. A metodologia explicará como o trabalho foi conduzido;
os resultados registrarão as evidências produzidas por esses procedimentos.

### Tratamento previsto das ilustrações

| ID | Rótulo atual | Achado confirmado | Encaminhamento na Fase 1 |
| --- | --- | --- | --- |
| B1 | `fig:comparativo-diagnosticos` | Montagem com `função principall`, `escreva` e exigência de ponto e vírgula incompatíveis com a Lumi | Preparar duas posições para capturas reais; propor programas equivalentes com o mesmo erro |
| B2 | `fig:carga-cognitiva-programacao` | Percentuais comparativos de carga cognitiva apresentados sem medição | Substituir por esquema qualitativo sem números nem proporções que representem ganhos |
| B3 | `fig:fluxo-resposta-erro` | Adaptação sem página e caixa de aplicação ao produto | Produzir síntese identificada como autoria própria; retirar a caixa de aplicação |
| B4 | `fig:arq_compilador` | Imagem contém AST anotada; o texto já informa que ela não é produzida | Redesenhar fases e artefatos reais, com retornos antecipados por falha quando necessários |
| B5 | `fig:ast-exemplo` | Atribuição com `:=` e legenda de cores inconsistente | Redesenhar em `forest` com `=`; distinguir esquema didático de captura da aba AST |
| B6 | `fig:arq_sistema` | Arquitetura genérica em camadas sem os contratos e módulos atuais | Produzir componentes e sequência da execução a partir do repositório |
| A2 | `graf:dispositivos-acesso-2023` | Gráfico só contém celular/computador e usa “distribuição” | Conferir fonte e recriar quatro meios de acesso em `pgfplots`, com denominador explícito |
| B7 | Novos rótulos | Faltam registros visuais do aplicativo | Preparar 12 ambientes: Home, editor/barra, autocompletar, erros léxico/sintático/semântico/de execução, Tokens, AST, depurador, mapa e aula |

Para B1, um par a preparar é o uso de identificador digitado incorretamente:
em C, declarar `int total = 15;` e usar `printf("%d\n", totla);` em um programa
completo com `#include <stdio.h>` e `main`; em Lumi, usar `var total = 15;`
e `print(totla);`. Ambos representam o uso de nome não declarado. As mensagens
e posições serão obtidas das ferramentas, não redigidas como se fossem saídas
observadas. A comparação ilustrará os dois diagnósticos sem atribuir superioridade
pedagógica a partir de uma captura.

### Conteúdo protegido

Os atuais Quadros 6 a 10 correspondem aos rótulos
`quad:validacao_tecnica`, `quad:perfil_participantes`,
`quad:respostas_tarefas`, `quad:usabilidade_participantes` e
`quad:temas_comentarios`. Contagens, frequências e medianas serão preservadas.
Percentuais poderão ser apresentados como contagens equivalentes, conforme J3,
sem recalcular ou mudar a base amostral. As bases de 11 consentidos e oito usuários
continuarão explícitas.

As seções 4.5.1 a 4.5.4 serão deslocadas com preservação do conteúdo técnico.
Quando o código atual divergir da versão nelas descrita, a atualização será
pontual e identificará a versão. O novo campo `const_value` é um caso concreto.
Nenhuma alteração de aplicativo está sendo realizada nesta revisão documental.

### Regras da UTP conferidas para a revisão final

| Tema | Páginas do manual | Aplicação prevista |
| --- | --- | --- |
| Fonte, títulos, margens, espaçamento e paginação | 15–17 | Conferir corpo 12, elementos menores 10, margens 3/2 cm, recuo 1,25 cm e hierarquia dos títulos |
| Siglas estrangeiras | 20 | Apresentar extenso e tradução na primeira ocorrência |
| Ilustrações e tabelas | 20–26 | Chamada próxima, título acima, fonte abaixo; tabelas estatísticas sem fechamento lateral |
| Folha de aprovação | 33–34 | Incluir após folha de rosto; manter dados de banca e aprovação pendentes |
| Resumos e palavras-chave | 35–37 | Resumo informativo de 150–500 palavras; tradução em folha própria; descritores minúsculos separados por ponto e vírgula |
| Listas e sumário | 38–43 | Correspondência com o corpo, lista própria de tabelas e símbolos em ordem de ocorrência |
| Introdução, desenvolvimento e conclusão | 44–46 | Explicitar escopo e objetivos; concluir com base nos resultados e no atendimento dos objetivos |
| Apêndices | 47–49 | Incorporar os instrumentos reais elaborados pelo autor |
| Citações | 52–62 | Sistema autor-data; distinguir paráfrase, citação direta e fonte efetivamente consultada |
| Referências | 64–72, 80–88, 92–97 e 111 | Conferir metadados e formatos de livros, artigos, eventos, normas e programas |

O estilo atual já define os títulos de terceiro nível sem negrito; permanece
necessário ajustar a capitalização dos títulos no texto. Não será introduzida
uma correção para um defeito de negrito que não foi observado.

Há duas particularidades do manual a registrar: as orientações de fontes de
ilustrações na p. 22 misturam descrição de sobrenomes em maiúsculas com exemplos
em caixa normal; e a p. 34 descreve o título “Folha de Aprovação”, mas o exemplo
visual traz “Termo de Aprovação”. O padrão textual final será uniforme; o modelo
da folha será confirmado com o orientador, como já prevê L10. As marcações
coloridas de pendências seguirão a instrução expressa do autor para a versão de
revisão, embora o manual preveja texto final em preto.

## 3. Pendências iniciais do autor

Nenhum `\autor{...}` foi inserido no LaTeX nesta fase. Os itens abaixo constituem
a lista inicial de informações e decisões que poderão originar os marcadores
visíveis a partir da Fase 1. As pendências não impedem preparar o documento com
espaços identificados; não serão preenchidas por suposição.

| Nº | Informação ou decisão necessária | Onde será usada | Prioridade |
| --- | --- | --- | --- |
| P01 | Identificação, versão, hash e arquivo do APK distribuído entre 9 e 13/11; informar se houve mais de uma compilação | H4, I9 e resultados da coleta | Alta |
| P02 | Enquadramento ético efetivamente definido com o orientador e eventual documento institucional correspondente | H7, seção de ética | Alta |
| P03 | Procedimentos adotados para consentimentos com e sem declaração de maioridade, sem inferir idades ausentes | H7, ética e validade | Alta |
| P04 | Tratamento, acesso, local e prazo de guarda de nomes, e-mails e respostas; destino dos registros excluídos | H7, seção de ética | Alta |
| P05 | Formulário aplicado de 20 questões na íntegra, com introdução, alternativas, saltos, códigos completos das tarefas e eventuais versões | H4/H5 e Apêndice C | Alta |
| P06 | Texto ou textos de consentimento efetivamente apresentados na coleta; distinguir eventual novo termo de um documento aplicado anteriormente | H5/H7 e Apêndice D | Alta |
| P07 | Canal de recrutamento, número de convites, datas, critérios e vínculo dos respondentes com o pesquisador | H4 e ameaças à validade | Alta |
| P08 | Comentários A01/A02 completos, anonimizados, e registros necessários para sustentar o cruzamento entre perfil e respostas neutras | J4/J5 e discussão dos iniciantes | Alta |
| P09 | Capturas reais do par GCC/Luminthor e das 12 situações listadas em B7, com identificação da versão usada | B1/B7, introdução e desenvolvimento | Alta |
| P10 | Decidir entre nova coleta observada com iniciantes e encerramento com avaliação exploratória de percepção; ajustar objetivo f em conjunto com o orientador | D5, H e J10 | Alta |
| P11 | Identificar o programa e a versão do caso divergente de T3, se preservados; permitir confrontar o relato com a reprodução técnica T2→T3 | J6, resultados | Alta |
| P12 | Instalar e comparar Portugol Mobile e WebStudio em celular; registrar versão, navegador quando aplicável, capturas e resultados por critério | G2/G4/G5 | Alta |
| P13 | Definir se serão traduzidos os rótulos `Execute`, `Trace`, `Settings` e `Templates`, ou justificar a manutenção | C5, limitações e Apêndice A | Média |
| P14 | Validar se palavras reservadas em inglês são uma escolha deliberada de projeto e fornecer sua justificativa; não atribuir intenção retrospectivamente | C1/C2 e linguagem Lumi | Média |
| P15 | Escolher o título definitivo entre alternativas mais precisas | D9, capa e folha de rosto | Média |
| P16 | Validar requisitos e escolhas da linguagem: intervalo de `for`, precedência de `not`, comparações encadeadas, `const` sem inicializador, ausência de entrada e vetores | H3 e I6 | Média |
| P17 | Fornecer registros adicionais das iterações e logs da verificação de 11/11, se existentes | H2 e I16 | Média |
| P18 | Fornecer ou realizar medições de análise/execução, memória, abertura e tamanho do APK com método e identificação de versão/aparelho | I13 e J1 | Alta |
| P19 | Realizar ensaios em dois ou três aparelhos, incluindo um de entrada: instalação, modo avião, persistência, arquivos e teclado | J1 e compatibilidade | Alta |
| P20 | Disponibilizar cobertura Rust/Flutter e resultado de `flutter analyze`, associados à mesma revisão, quando produzidos | I16 e J1 | Média |
| P21 | Informar URL pública do repositório e tag da versão documentada; o commit local existe, mas isso não comprova uma tag de entrega | I18 e reprodução | Média |
| P22 | Confirmar dados e modelo de folha de aprovação, integrantes da banca, titulações e data quando definidos | L10, pré-textuais | Média |
| P23 | Informar o protocolo de busca realmente realizado ou revisar um protocolo complementar a executar; não tratar busca proposta como procedimento histórico concluído | G3, metodologia e trabalhos relacionados | Média |

Os recortes de renda da PNAD e as páginas dos artigos serão procurados nas fontes
originais antes de serem transferidos ao autor como pendências. Da mesma forma,
comportamentos do motor disponíveis no repositório não serão solicitados ao autor
como se o código-fonte estivesse ausente.

### Alternativas de título para decisão posterior

1. **Luminthor: ambiente móvel com interpretador didático local para o ensino de lógica de programação.**
2. **Desenvolvimento do Luminthor: ambiente Android com linguagem didática e visualização da execução de programas.**
3. **Luminthor: ambiente Android para edição, análise e interpretação local de programas didáticos.**

Nenhum título foi substituído nesta fase. “Para o ensino” exprime finalidade;
não constitui afirmação de aprendizagem demonstrada.

Para o objetivo f, preparar duas redações na Fase 3: uma centrada em uso observado
por iniciantes, caso haja nova coleta, e outra centrada em usabilidade percebida
por participantes voluntários, caso permaneçam apenas os dados atuais.

## 4. Referências a verificar

Nenhum `\verificar{...}` foi inserido e nenhuma referência foi acrescentada nesta
fase. A leitura do manual institucional foi concluída. As demais fontes abaixo
compõem a fila de conferência, não uma lista de referências já validadas.

| Identificação | Fonte ou conjunto | O que conferir | Fase |
| --- | --- | --- | --- |
| V01 | Bennedsen e Caspersen (2007; 2019); Watson e Li (2014) | Metadados, amostras, taxas, denominadores e interpretação dos próprios autores | 1 |
| V02 | Tims et al. (2024), PDF local `StudentEnrollment.pdf` | Limitar uso a matrícula, conclusão e retenção no contexto efetivamente estudado | 1 |
| V03 | PNAD Contínua TIC 2023, PDF local e publicação original; Meirelles (2025) | Quatro meios de acesso, população com dez anos ou mais, recorte de estudantes, renda e distinção entre estoque de aparelhos e acesso individual | 1 |
| V04 | Algaraibeh, Dousay e Jeffery (2020), `IntegratedLearning.pdf` | Escopo de trabalho em andamento; suporte para funcionalidades descritas; excluir resultados sem lastro | 1 |
| V05 | Gwendo e Chepkwony (2020), `JohnOloo.pdf` | Autoria, DOI, páginas e significado dos percentuais; há divergência com a revisão local antiga, que registra 45,9% para tela pequena, enquanto o texto mantém 31,2% | 1 |
| V06 | Marceau, Fisler e Krishnamurthi (2011), SIGCSE e Onward! | Distinguir os dois artigos, desambiguar 2011a/2011b, conferir sequência cognitiva e recomendação sobre sugestões | 1 e 4 |
| V07 | Neri, Dias e Gurjão (2025), `LogicProg.pdf` | Concurso Apps.Edu, natureza do relato, páginas 140–143 e alegações permitidas | 1 |
| V08 | Slany (2014), `PocketCode.pdf`; Noschang et al. (2014), `PortugolStudio.pdf` | Limites de um resumo de demonstração; recursos comprovados; evitar atribuir superioridade pedagógica sem estudo | 1 |
| V09 | Qian e Lehman (2017) | Referência original e suporte para cada uma das quatro concepções equivocadas | 1 e 4 |
| V10 | Becker et al. (2019); Becker (2016); Denny, Luxton-Reilly e Carpenter (2014) | Resultados favoráveis e nulos sobre mensagens, contextos e condições dos estudos | 4 |
| V11 | Sorva (2013); Sorva, Karavirta e Malmi (2013); Guo (2013) | Máquina nocional, visualização e limites da evidência para fundamentar o depurador | 4 |
| V12 | Guo (2018); Dasgupta e Hill (2017); Hermans (2020) | Idioma, localização de linguagens, público e resultados; não usar como prova de transferência da Lumi | 2 e 4 |
| V13 | ISO 9241-11:2018; Nielsen (1993); Brooke (1996) e fontes sobre amostras de usabilidade | Conceitos, instrumento SUS e tamanho de amostra; não converter os itens próprios em SUS retrospectivamente | 4 |
| V14 | Louden; Cooper e Torczon; Nystrom; Levenshtein; Gamma et al. | Edição, autoria e metadados; fundamentos de parser, interpretação, distância e Visitante | 4 |
| V15 | Documentação oficial de Flutter, Rust, FFI, flutter_rust_bridge, logos, Riverpod, Hive, GoRouter e MVVM; Tillmann et al. | Recursos e limitações das versões utilizadas, AOT e programação por toque; registrar acesso real | 4 |
| V16 | Literatura de carga cognitiva e exemplos resolvidos | Terminologia em português para germane load e suporte ao sequenciamento de exemplos/aulas | 4 |
| V17 | Portugol Mobile/WebStudio, VisuAlg, Python Tutor, Thonny, Pydroid 3 e Sololearn | Fontes primárias, autores, versões e recursos; instalações de loja são dados datados e não prova de adequação pedagógica | 4 |
| V18 | Wazlawick; Gil; Hevner et al.; Peffers et al. | Enquadramento metodológico e o que do processo é documentado; não afirmar adoção histórica de DSR sem correspondência | 5 |
| V19 | Todas as entradas já existentes no `.bib` | Formato UTP, nomes próprios protegidos, local/evento/editora, paginação, DOI, URL e correspondência com as citações | 1 e 8 |

As páginas de citação serão extraídas das fontes consultadas. Ausência de acesso
ou de confirmação produzirá uma marcação visível no documento nas fases de edição.
O fato de uma referência estar sugerida no roteiro não dispensa essa conferência.

## 5. Dúvidas que bloqueiam a próxima fase

**Não há bloqueio para iniciar a Fase 1 após “continue”.** O LaTeX, o repositório,
os PDFs locais relevantes e o manual da UTP estão disponíveis. Onde faltarem
capturas ou fontes confirmadas, a Fase 1 poderá avançar com as marcações visíveis
previstas no roteiro.

As decisões sobre nova coleta, rótulos, título e enquadramento ético serão
necessárias nas fases correspondentes. Sua ausência não autoriza presumir
respostas, alterar registros de coleta ou preencher dados empíricos.

### Sequência de execução preservada

| Fase | Escopo | Itens do roteiro | Entrega prevista |
| --- | --- | --- | --- |
| 0 | Diagnóstico | Estrutura e pendências | Este relatório; fontes preservadas |
| 1 | Credibilidade | A e B | Citações corrigidas ou marcadas, figuras vetoriais e espaços de captura |
| 2 | Idioma | C | Motivação e critérios de português qualificados, discussão da escolha de palavras reservadas |
| 3 | Estrutura | D | Sete capítulos e introdução reorganizada; deslocamentos sem perda de conteúdo |
| 4 | Teoria e relacionados | F e G | Fundamentação ampliada e comparação única baseada em evidências |
| 5 | Método e ética | H | Requisitos, rastreabilidade, procedimentos, ética, ameaças e instrumentos reais ou pendentes |
| 6 | Desenvolvimento | I | Especificação conferida no código, exemplos reais, catálogo, trilha, testes e tabelas de medição |
| 7 | Resultados | J | Dados preservados, discussão sustentada pela literatura e evidências técnicas identificadas |
| 8 | Fechamento | K, E, L e M | Conclusão, resumo/Abstract, normas, bibliografia, tipografia e verificação final |

Os ajustes de redação estritamente necessários acompanharão a correção de cada
fase; a padronização global de E fica concentrada no fechamento. A verificação
de todos os critérios de pronto da seção 7 do roteiro ocorrerá ao final da Fase 8.

### Verificações realizadas nesta fase

- Inventário dos capítulos, inclusões, quadros, figuras, gráfico e referências.
- Checagem estática de `ref`, `pageref` e `autoref` contra rótulos ativos dos
  arquivos principal e de apêndices: nenhum destino ausente e nenhuma duplicação
  encontrados nesse escopo. Isso não certifica a bibliografia nem a compilação.
- Inspeção visual das sete imagens incluídas e de páginas selecionadas do PDF
  atual, além dos modelos relevantes do manual institucional.
- Localização de `latexmk`, `pdflatex`, `bibtex` e ferramentas de leitura/renderização
  de PDF no ambiente. Não foi executada nova compilação, suíte Rust, suíte Flutter,
  cobertura ou medição em aparelho nesta fase.

Para rastrear a preservação, os SHA-256 dos arquivos principais lidos são:

```text
trabalho.tex
4edeefc9bf6100aa0e163d6ed9a7dcb51547ae3994af8eb660f986685d245894
apendices/manuais.tex
9369872604fecbec6f3092517a4b04bb04a59c72e123d9ade354931f18af6dc1
referencias.bib
acb1a3c47eb67016f8b8b4f3e2383f31c2b7e3243369e7c7ed25d4615ec5e937
packages/abnt-UTP.sty
8b5001333fcbdfab977a9bd9177467b11cd838fc40e0e4e3b70560568992b9be
trabalho.pdf
1280ce8421a0d74d20b499ae2fa25d224290d7b75e803d04d84b5a5cb66d3678
```

Próxima etapa: **Fase 1 — credibilidade das citações e figuras**, somente após a
manifestação “continue”, conforme solicitado no roteiro anexado.
