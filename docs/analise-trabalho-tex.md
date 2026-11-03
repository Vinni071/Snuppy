# Análise do trabalho.tex para a entrega do PG II

Revisão de 28/10/2026, com referência à exigência de entrega para a banca em
14/11/2026 fornecida pelo aluno. As linhas abaixo correspondem ao arquivo lido nesta
revisão; a monografia não foi alterada.

Arquivo: `TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex`.

## 1. O que já está escrito

| Parte | Linha inicial | Conteúdo existente | Situação |
| --- | ---: | --- | --- |
| Identificação e pré-textuais | 16 / 77 | Título, autor, orientador, instituição, capa, folha de rosto, resumo, palavras-chave, listas, siglas, símbolos e sumário | Presentes; precisam de revisão final |
| Introdução | 179 | Contextualização, justificativa, problema de pesquisa, objetivo geral, seis objetivos específicos e apresentação da metodologia | Escrita; revisar promessas e dados citados |
| Fundamentação teórica | 291 | Carga cognitiva, dificuldades iniciais, acesso a equipamentos, aprendizagem móvel, compiladores, gramática, AST, análise semântica, mensagens e execução local | Desenvolvida; há correções de fontes e coerência |
| Trabalhos relacionados | 916 | Portugol Studio, ambiente de Algaraibeh, Ubi-C, DIMP, Pocket Code, LogicProg e estudo de Oloo; síntese comparativa | Desenvolvidos; revisar atribuições aos artigos |
| Caracterização e procedimentos | 1115 / 1139 | Pesquisa aplicada, R&D, prototipagem evolutiva e etapas da construção | Escritos |
| Arquitetura | 1170 | Interface, estado/persistência, FFI e motor Rust, com figura e contrato da API | Escrita |
| Linguagem Lumi | 544 / 1220 | EBNF, precedência, construções, justificativas e limitações da sintaxe | Escrita |
| Ferramentas | 1277 | Rust, Flutter/Dart, Riverpod, Hive, GoRouter, flutter_rust_bridge e logos, com justificativas | Escritas; não falta criar um capítulo separado apenas para isso |
| Implementação | 1298 | Pipeline, estruturas de dados, algoritmos, editor, diagnósticos e depurador | Descrita em detalhe |
| Estratégia de testes | 1542 | Testes Rust, FFI real e widgets, com critérios de verificação | Escrita |
| Resultados técnicos | 1569 | 65 testes Rust e 58 Flutter aprovados, quadro e descrição de comportamentos cobertos | Existem; falta ampliar sua apresentação e discussão |
| Protocolo com usuários | 1607 | Amostra planejada, sessões, cinco tarefas, critérios, oito itens Likert, perguntas abertas e análise prevista | Planejamento escrito; não há resultados coletados apresentados |
| Considerações finais | 1700 | Síntese do protótipo, testes, limitações e continuidade | Redigidas como encerramento de etapa parcial |
| Referências | 2535 | Bibliografia carregada de referencias.bib, com 13 entradas selecionadas | Presente; revisar atribuições, metadados e correspondência |

As sete imagens efetivamente incluídas foram encontradas. A verificação estática
dos comandos `ref`, `pageref` e `autoref` não encontrou destinos ausentes, nem
duplicações entre os identificadores examinados. Isso não substitui compilar e
inspecionar visualmente o PDF final.

## 2. Situação dos seis objetivos específicos

Os objetivos estão nas linhas 249 a 254.

| Objetivo | O que o texto já apresenta | Evidência ou ajuste pendente |
| --- | --- | --- |
| 1. Interface adaptada ao toque | Arquitetura e descrição do editor, atalhos, temas e testes de widgets | Capturas reais e registro do uso com teclado no celular |
| 2. Gramática formal da Lumi | EBNF, precedência, separadores, chamadas e limitações | Revisão final de coerência; não está ausente |
| 3. Análises executadas localmente no móvel | Módulos Rust, integração FFI e resultados de testes | Registrar execução da versão entregue em aparelho físico e sem conexão |
| 4. Diagnósticos formativos e intenção provável | Classes de erro, posições, sugestões e Levenshtein | Delimitar a expressão "intenção provável" às regras efetivamente descritas; apresentar casos concretos |
| 5. Depurador de teste de mesa | Dados dos passos, memória, escopos, pilha e saída acumulada | Mostrar uma sequência real, com programa e valores esperados/observados |
| 6. Avaliação com iniciantes | Protocolo detalhado | Realizar e analisar o estudo, ou ajustar formalmente esse objetivo com o orientador |

Esta tabela classifica a documentação e as evidências apresentadas no texto. Ela
não afirma nova aprovação de testes ou validação dos aparelhos.

## 3. O que falta acrescentar para fechar o texto

### 3.1 Resultados e discussões identificáveis

Não existe seção ou capítulo intitulado Resultados e Discussões. Há uma subseção
com resultados técnicos dentro da metodologia, na linha 1569. Portanto, não é
correto dizer que o trabalho não tem resultado algum.

Para atender à exigência e permitir avaliação pela banca, consolidar:

1. Versão do código avaliada, data, ferramentas, sistema e aparelhos utilizados.
2. Programas representativos, resultados esperados e observados, diagnósticos e
   estados do depurador. Relacionar os casos às funcionalidades e objetivos.
3. Resultados dos testes automatizados, aproveitando o quadro existente, com
   delimitação da cobertura. Identificar quais registros correspondem à entrega.
4. Uso em celular físico, execução sem rede, persistência, teclado e arquivos.
5. Resultados da avaliação com usuários, se esse objetivo permanecer no trabalho.
6. Discussão do significado dos resultados, dificuldades, limitações, contribuição
   e relação com os trabalhos relacionados.

Um capítulo próprio é uma organização recomendada, não uma exigência de título
deduzida do enunciado. Apenas mover o quadro de testes não completa a discussão.

### 3.2 Evidências visuais do aplicativo

As figuras incluídas são conceituais ou de arquitetura. Não há capturas incluídas
da interface em execução. Nas linhas 1433 e 1525 há comentários sugerindo imagens
do editor e do depurador, sem comandos ativos que as insiram.

Acrescentar capturas do editor/saída, diagnóstico, tokens/AST e depurador, agrupadas
quando isso ajudar a leitura. Cada imagem deve acompanhar a explicação de um
comportamento observado, e não apenas decorar a apresentação.

### 3.3 Avaliação com usuários

O texto da linha 1607 em diante é um protocolo no futuro. A linha 1603 declara
explicitamente a ausência de dados móveis, de aprendizagem e de satisfação.
Não aparecem amostra efetiva, datas, registros coletados, resultados por tarefa,
respostas do questionário ou análise das respostas abertas.

Se o estudo for realizado, acrescentar esses dados e explicar desvios do protocolo.
Disponibilizar os códigos exatos das tarefas e critérios de pontuação; atualmente
o quadro apresenta os enunciados gerais, mas os programas T1/T3/T4/T5 não estão
incluídos como instrumentos completos.

O protocolo mede execução de tarefas, compreensão e percepção de uso. Isso não
constitui automaticamente medição de ganho de aprendizagem. Ajustar o objetivo
"eficácia pedagógica" à evidência que o desenho permite produzir. Justificar os
limiares exploratórios de 80% e 75% e definir como o critério geral de compreensão
agrega as respostas de T3, T4 e T5.

### 3.4 Conclusões e resumo

A conclusão começa na linha 1703 dizendo que o trabalho ainda está em
desenvolvimento e volta a apresentar resultados parciais na linha 1726.
Reescrevê-la após a avaliação para responder à pergunta de pesquisa, informar o
atendimento dos seis objetivos e separar limitações de trabalhos futuros.

O resumo da linha 83 já apresenta tema, objetivo, método e produto. Acrescentar
os principais resultados efetivamente obtidos e a conclusão correspondente.
Atualizar também o parágrafo que apresenta a organização dos capítulos, na linha
276, caso a estrutura mude.

### 3.5 Pré-textuais

Não há resumo em língua estrangeira nem folha de aprovação inseridos no arquivo
principal. Conferir os elementos aplicáveis à versão para banca no modelo/manual
da UTP. Não preencher aprovação ou dados de banca que ainda não foram definidos.

As referências já atendem à existência de elementos pós-textuais. Apêndices e
anexos estão apenas exemplificados em comentários; não devem ser inventados para
preencher o documento. Um apêndice com os instrumentos reais da avaliação seria útil.

## 4. Correções de conteúdo encontradas

Foram confrontadas afirmações específicas com os PDFs locais. Não se trata de uma
auditoria integral de todas as referências.

| Local no trabalho.tex | Problema encontrado | Correção necessária |
| --- | --- | --- |
| 949–959 | O artigo de Algaraibeh usa a sigla ILDE; é apresentado como trabalho em andamento, com avaliação futura. Não sustenta o resultado de redução de aproximadamente 35% no tempo de correção. Também não foi encontrada base nele para a descrição como plugin Eclipse/VS Code. | Corrigir a sigla no texto, na lista de siglas e no quadro; descrever a proposta do artigo e retirar o resultado atribuído sem suporte, ou fornecer outra fonte que realmente o apresente. |
| 843–845 e 1021–1024 | Oloo relata 67,6% para erros/bugs. O texto transforma essa categoria em incompreensão de mensagens não traduzidas. O valor de tela pequena no artigo é 45,9%, não 31,2%. | Corrigir percentual e interpretação; não equiparar a categoria erros/bugs a uma medição específica da clareza ou tradução dos diagnósticos. |
| 379–380 | A faixa global de 30% a 50% de reprovação em disciplinas introdutórias é atribuída a Tims. O PDF trata matrícula, conclusão e retenção de cursos superiores nos EUA; não apresenta suporte para essa afirmação específica. | Substituir por fonte que meça reprovação introdutória ou reformular usando o indicador e a população realmente estudados. Revisar também a atribuição semelhante da introdução. |
| 452–456 | A afirmação de melhora significativa e de motivação fora do horário de aula não está demonstrada no PDF local do LogicProg, que é um resumo de apresentação do aplicativo. | Limitar a descrição ao que o documento informa ou citar o estudo completo que apresente os resultados mencionados. |
| 214–217 e 399–402 | O percentual de 34,2% é descrito como população geral. O informativo do IBGE trata pessoas de 10 anos ou mais que utilizaram internet e o equipamento de acesso. | Corrigir o denominador e manter a população de referência explícita. |
| 904 versus 1227–1230 | A síntese da lacuna pede linguagem em português, mas a Lumi é descrita com palavras reservadas em inglês e mediação pedagógica em português. | Uniformizar a contribuição como linguagem textual didática com interface e diagnósticos em português. |
| 1058–1062 | "Nenhum trabalho existente" é uma afirmação universal, mais ampla que o conjunto apresentado na revisão. | Delimitar para "entre os trabalhos analisados" e explicar as dimensões utilizadas na comparação. |
| 1015 | "Qualquer algoritmo" excede o escopo reduzido da linguagem descrito na metodologia. | Restringir a programas compatíveis com as construções implementadas na Lumi. |
| 157 versus 557 | Sigma é descrito como somatório na lista, mas representa o conjunto de terminais na definição da gramática. | Corrigir a lista e revisar símbolos herdados do template. |

Fontes locais utilizadas nessas conferências:

- `TCC_Teorico/Referencias/IntegratedLearning.pdf`, especialmente Evaluation e Summary.
- `TCC_Teorico/Referencias/JohnOloo.pdf`, especialmente a seção de discussão dos resultados.
- `TCC_Teorico/Referencias/StudentEnrollment.pdf`, escopo e indicadores do relatório.
- `TCC_Teorico/Referencias/LogicProg.pdf`, resumo publicado na página 140.
- `TCC_Teorico/Referencias/pnad-acesso-internet-ibge-16ago2024.pdf`, equipamento utilizado para acessar internet.

Outros ajustes de revisão: dar referência apropriada à apresentação de Sweller
(1988), ausente como entrada na bibliografia; distinguir requisitos móveis propostos
nas linhas 791–793 de requisitos medidos; esclarecer os critérios dos quadros
comparativos, incluindo o sentido de "Parcial" e de "Português"; conferir metadados
das referências e as citações escritas manualmente por macros.

## 5. Material comentado não é conteúdo pendente do PDF

Depois da conclusão existe um trecho extenso de exemplos do template: citações,
figuras, tabelas, algoritmos e cronograma. Esses exemplos estão comentados e não
constituem capítulos ativos. As sugestões de imagens também não são exigências
automáticas: algumas já têm figura correspondente; outras podem ser descartadas.

## 6. Ordem de fechamento

1. Corrigir atribuições e números das fontes.
2. Fechar com o orientador o escopo da avaliação do sexto objetivo.
3. Registrar os testes e o uso em celular da versão entregue; executar a avaliação
   acordada e conservar os dados reais.
4. Consolidar resultados e discussões, aproveitando os testes já documentados.
5. Reescrever conclusões e resumo e revisar o atendimento dos objetivos.
6. Conferir pré-textuais, referências, formatação e PDF final; preparar programa e
   instruções da mesma versão da monografia para a submissão.

Não é possível preencher resultados empíricos ausentes apenas revisando o LaTeX.
Por outro lado, a gramática, a arquitetura, as ferramentas e os algoritmos já têm
descrição substancial e não precisam ser escritos novamente do zero.
