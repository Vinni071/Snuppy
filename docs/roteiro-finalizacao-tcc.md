# Roteiro de conclusão do Luminthor — PG II

Diagnóstico de 28/10/2026. Prazo confirmado pelo aluno: **14/11/2026**.
Este documento organiza as pendências; não altera a monografia nem o aplicativo.

## Referência da entrega

A exigência mais recente fornecida pelo aluno é a entrega para a banca do **PG II**:
monografia com elementos pré-textuais, introdução, fundamentação teórica, trabalhos
relacionados, metodologia de construção da solução, ferramentas para implementação,
resultados e discussões, conclusões e elementos pós-textuais; postagem do programa
implementado e, se necessário, instaladores; formatação ABNT/UTP.

A linha de PG I enviada antes foi substituída por essa exigência. A avaliação com
alunos não está explicitamente exigida nesse enunciado, mas está entre os objetivos
específicos da monografia atual. Essa diferença precisa ser resolvida no trabalho.

## Diagnóstico

O projeto já tem conteúdo técnico para sustentar a apresentação de um artefato:
linguagem Lumi, lexer, parser, AST, análise semântica, interpretador, diagnósticos em
português, interface Flutter, integração FFI, arquivos e depurador por rastro.
A contribuição pode ser delimitada como a construção e avaliação técnica de uma IDE
didática com execução local e visualização do processamento dos programas.

As principais pendências são consolidar a avaliação, discutir os resultados e
preparar uma entrega reproduzível. A revisão não demonstrou eficácia pedagógica,
funcionamento em telefone físico ou conformidade integral com as normas.

| Exigência | Evidência encontrada | Trabalho de fechamento |
| --- | --- | --- |
| Elementos pré-textuais | Capa, folha de rosto, resumo, listas e sumário | Conferir o conjunto aplicável à entrega e revisar o PDF; não há resumo em língua estrangeira no arquivo principal |
| Introdução | Problema, justificativa, objetivo geral e objetivos específicos | Alinhar promessas ao que será efetivamente avaliado |
| Fundamentação teórica | Capítulo próprio | Revisar pertinência das afirmações, citações e ligação com as decisões do projeto |
| Trabalhos relacionados | Capítulo e quadros comparativos | Explicar a contribuição da integração proposta e os limites da comparação |
| Metodologia e ferramentas | Arquitetura, gramática, estruturas, algoritmos, Rust, Flutter e FFI | Distinguir procedimentos realizados e avaliação ainda planejada |
| Resultados e discussões | Resultados técnicos em uma subseção da metodologia | Consolidar uma seção ou capítulo identificável, com evidências, análise e limitações |
| Conclusões | Considerações finais de trabalho em desenvolvimento | Responder à pergunta de pesquisa e informar o atendimento de cada objetivo |
| Elementos pós-textuais | Referências bibliográficas | Conferir correspondência entre citações e referências; avaliar necessidade de apêndices para instrumentos e exemplos |
| Programa implementado | Código-fonte, instruções e APK local encontrado | Gerar/verificar a versão da entrega e testar a instalação e o uso |
| ABNT/UTP | Modelo LaTeX institucional e PDF existente | Fazer conferência final; usar um modelo não comprova sozinho conformidade |

## Prioridade 1 — Fixar o escopo e a avaliação

- [ ] Congelar a adição de funcionalidades até a entrega. Corrigir defeitos que
  impeçam executar, salvar, diagnosticar ou demonstrar os exemplos escolhidos.
- [ ] Resolver com o orientador o objetivo de avaliar usuários iniciantes. Se ele
  permanecer no escopo, executar e documentar a avaliação. Se não for viável,
  negociar a delimitação e atualizar introdução, metodologia, resumo e conclusões.
- [ ] Tratar avaliação de usabilidade e compreensão das mensagens com esses nomes.
  O protocolo atual não constitui, por si só, uma medição de ganho de aprendizagem.
- [ ] Delimitar a contribuição: explicar como os recursos integrados apoiam as
  tarefas propostas e quais aspectos foram efetivamente observados.

O [protocolo já escrito](../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex) contém
cinco tarefas, questionário, critérios de sucesso e análise proposta. Não é
necessário criar um novo protocolo do zero. Ele prevê 10 a 20 participantes;
qualquer mudança na amostra ou nas tarefas deve ser descrita e justificada.
Caso seja executado, seguir as condições de participação previstas nele.

## Prioridade 2 — Produzir evidências do programa entregue

- [ ] Repetir compilação e testes na versão selecionada para a entrega, guardando
  versão do código, ambiente, comandos e resultados.
- [ ] Instalar o APK dessa versão em um Android físico. Registrar modelo, versão do
  Android e versão do aplicativo. Um aparelho delimita a evidência àquele aparelho.
- [ ] Executar sem conexão: criar um arquivo, editar, executar, fechar, reabrir e
  verificar a persistência; importar e exportar um arquivo.
- [ ] Demonstrar expressão aritmética, condicional, repetição, função e escopos.
- [ ] Demonstrar erro léxico, sintático, semântico e de execução, com a localização
  e a explicação apresentadas ao usuário.
- [ ] Avançar e retroceder no depurador, verificando variáveis, escopos e saída.
- [ ] Verificar teclado, rotação e legibilidade no aparelho utilizado.
- [ ] Registrar capturas reais e uma tabela com caso, resultado esperado, observado
  e situação. Documentar também falhas e limitações encontradas.
- [ ] Se apresentar tempos ou consumo de recursos, registrar método, programas,
  aparelho e repetições. Não chamar o motor de alto desempenho apenas por usar Rust.

O arquivo `build/app/outputs/flutter-apk/app-release.apk` existe no workspace,
mas sua correspondência com a versão da entrega e seu funcionamento não foram
verificados nesta revisão. Não é necessário publicar em uma loja para cumprir a
postagem do programa descrita no enunciado.

## Prioridade 3 — Escrever resultados, discussão e conclusões

Estrutura sugerida para resultados e discussões:

1. **Versão avaliada e ambiente:** identificar código, ferramentas e dispositivos.
2. **Resultados funcionais e de integração:** apresentar os casos avaliados e os
   testes, relacionando-os aos requisitos; incluir imagens do aplicativo real.
3. **Resultados no dispositivo móvel:** relatar instalação, execução local,
   persistência e interação, com os limites dos aparelhos utilizados.
4. **Avaliação com usuários, se realizada:** informar amostra efetiva, tarefas,
   resultados, dificuldades e alterações decorrentes. Separar uso com e sem auxílio.
5. **Discussão:** explicar o que as evidências sustentam, o que ainda não permitem
   concluir e como a solução se relaciona aos trabalhos estudados. Distinguir
   comparação de funcionalidades de comparação experimental de desempenho.
6. **Limitações:** amostra, dispositivos, cobertura dos casos, linguagem reduzida e
   ausência de evidência de aprendizagem, quando essa evidência não foi coletada.

A conclusão deve retomar a pergunta de pesquisa e cada objetivo específico,
classificando seu atendimento com base nos resultados apresentados. O resumo deve
refletir esses mesmos resultados. Reconhecer limitações não impede concluir um
trabalho com escopo definido.

Pontos específicos de revisão encontrados:

- O último objetivo específico promete avaliar usabilidade e eficácia pedagógica;
  os resultados atuais são técnicos e o protocolo permanece planejado.
- A conclusão começa dizendo que o trabalho ainda está em desenvolvimento. Para a
  versão final, apresentar o artefato concluído dentro do escopo e suas limitações.
- A expressão "identificando a intenção provável do aluno" precisa ser delimitada
  às regras e sugestões realmente implementadas, como similaridade de nomes.
- A lista de símbolos chama `Sigma` de somatório, mas a definição de gramática usa
  o símbolo para o conjunto de terminais. Ajustar a descrição ao uso no texto.
- Existem figuras com a denominação anterior Snuppy, explicada no texto. Uniformizar
  a apresentação como Luminthor, se possível, para facilitar a leitura.
- Não há abstract no arquivo principal. O manual institucional orienta a apresentação
  de tradução do resumo; conferir os pré-textuais aplicáveis à entrega e incluí-los.

Referência para conferência formal: [Normas Técnicas UTP](https://tuiuti.edu.br/wp-content/uploads/2024/09/e-book_NT_UTP_2024-1.pdf).
Esta revisão não substitui a conferência integral do manual e das orientações da disciplina.

## Prioridade 4 — Preparar a entrega

- [ ] Compilar o PDF final e conferir sumário, paginação, figuras, quadros, códigos,
  citações e referências; verificar ausência de referências indefinidas.
- [ ] Separar código-fonte, dependências declaradas, bindings e instruções de
  compilação/execução. Evitar incluir caches e diretórios de build desnecessários.
- [ ] Entregar o APK testado, com instruções curtas de instalação e uso.
- [ ] Conferir que monografia, programa e registros descrevem a mesma versão.
- [ ] Preparar uma demonstração curta: programa correto, diagnóstico e correção,
  tokens/AST e acompanhamento das variáveis no depurador.
- [ ] Submeter PDF e programa no ambiente da disciplina e conferir os arquivos enviados.

O pacote de checkpoint de 10/10 é um registro anterior, não a entrega final.

## Cronograma sugerido até 14/11

| Período | Resultado a produzir |
| --- | --- |
| 28 a 30/10 | Escopo fechado, decisão sobre avaliação com usuários e versão para testar no celular |
| 31/10 a 04/11 | Registros dos testes e da avaliação acordada; correção das falhas impeditivas |
| 05 a 08/11 | Resultados e discussões escritos a partir dos dados efetivamente obtidos |
| 09 a 11/11 | Conclusões, resumo, pré-textuais, referências e revisão de coerência |
| 12 a 13/11 | PDF conferido, APK testado, pacote e demonstração preparados |
| 14/11 | Envio e conferência da submissão |

## Limites desta revisão

Foram lidos o código principal, os testes, a monografia LaTeX, o texto extraído do
PDF e os registros do checkpoint. O checkpoint registra **65 testes Rust e 58
testes Flutter aprovados**. A repetição nesta sessão não foi concluída: o Cargo
offline precisava baixar `diff v0.1.13`, e o Flutter tentou escrever no cache de
um SDK localizado fora das áreas graváveis. Essas interrupções não demonstram
defeito no aplicativo nem confirmam aprovação atual das suítes.

Não houve teste em telefone físico, coleta de dados com alunos, inspeção visual
integral do PDF ou certificação de conformidade ABNT/UTP nesta sessão.
