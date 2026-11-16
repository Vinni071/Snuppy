# Pendências consolidadas da revisão final do TCC Luminthor

Data: 15/11/2026. Inventário dos marcadores visíveis dos fontes da Fase 8.
A numeração P/V é deste inventário, não identifica participantes nem requisitos.
São **42 pendências do autor** (28 `\autor{}` e 14 capturas) e
**21 verificações de fontes ou dados**. Itens relacionados continuam separados
quando correspondem a marcadores diferentes, para permitir sua localização.

Prioridades: **1** — documentos e integridade da coleta; **2** — evidências,
reprodução e comparação; **3** — decisões, referências e apresentação;
**4** — preparação de estudo futuro, somente se for retomado.
A coleta com cinco a oito iniciantes permanece proposta futura por decisão do autor.

## Pendências do autor, em ordem de prioridade

1. **P01 — prioridade 1** — [apendices/instrumentos.tex:9](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/instrumentos.tex). fornecer o formulário efetivamente aplicado na íntegra: apresentação, instruções, 20 questões, códigos e programas das tarefas, alternativas de resposta, obrigatoriedade dos campos e regras de salto; preservar as datas e diferenças entre versões, caso tenham sido utilizadas.

2. **P02 — prioridade 1** — [apendices/instrumentos.tex:31](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/instrumentos.tex). fornecer o texto de consentimento efetivamente apresentado aos participantes, incluindo informações prévias, contato, direitos, opções de aceite e recusa e suas eventuais versões e datas; reproduzir o documento sem dados pessoais dos respondentes.

3. **P03 — prioridade 1** — [capitulos/comentarios-integrais.tex:7](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/comentarios-integrais.tex). fornecer os textos completos de A01 e A02, com códigos estáveis de participante e indicação do campo, sem nomes, e-mails ou outros identificadores. Preservar a redação e sinalizar eventuais supressões de dados pessoais; não reconstruir falas a partir das categorias resumidas.

4. **P04 — prioridade 1** — [capitulos/resultados-tecnicos-complementares.tex:46](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/resultados-tecnicos-complementares.tex). realizar ensaio em dois ou três celulares, incluindo um de entrada; registrar modelo, categoria, Android, versão e hash SHA-256 do APK, data e responsável; verificar instalação, execução em modo avião, persistência após encerrar e reabrir, importação, exportação e interação com o teclado. Preencher a tabela e anexar as evidências, mantendo campos vazios enquanto o ensaio não for executado.

5. **P05 — prioridade 1** — [trabalho.tex:1684](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). explicar quando, por que e por quem o LUMI-AV02 foi alterado para o formulário de 20 questões; informar a justificativa original para utilizar instrumento próprio em lugar de uma escala validada.

6. **P06 — prioridade 1** — [trabalho.tex:1701](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar canal de recrutamento, número de convites, vínculo dos participantes com o autor e eventuais incentivos; os 12 envios não permitem inferir quantas pessoas foram convidadas.

7. **P07 — prioridade 1** — [trabalho.tex:1706](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar versão e hash SHA-256 do APK distribuído; esclarecer se houve mais de uma versão entre 9 e 13/11/2026 e, se possível, relacioná-las aos envios sem publicar identificadores pessoais.

8. **P08 — prioridade 1** — [trabalho.tex:1783](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar quem categorizou os comentários, como os temas foram definidos e revisados e como foi tratada a repetição de um tema nos dois campos de uma mesma pessoa; confirmar se houve mais de um avaliador. Não atribuir concordância entre avaliadores ou saturação sem registros correspondentes.

9. **P09 — prioridade 1** — [trabalho.tex:1801](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar o enquadramento ético definido com o orientador e o registro institucional correspondente, incluindo norma aplicável, parecer ou fundamento de eventual dispensa. Não há documento fornecido que permita afirmar aprovação ou dispensa nesta monografia.

10. **P10 — prioridade 1** — [trabalho.tex:1808](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). descrever tratamento e guarda de nomes e e-mails: local e responsável, pessoas com acesso, separação dos dados de análise, prazo de retenção e destinação; informar o procedimento de retirada de dados efetivamente comunicado e adotado.

11. **P11 — prioridade 1** — [trabalho.tex:1815](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar, com o orientador, como serão tratados os registros sem declaração de maioridade e documentar a decisão; se o critério de inclusão mudar, atualizar os agregados e todos os resultados correspondentes.

12. **P12 — prioridade 2** — [capitulos/reproducao-t3.tex:48](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/reproducao-t3.tex). reproduzir no APK e no aparelho a sequência de T2 sem correção seguida de T3; registrar separadamente substituir todo o texto e acrescentar o novo programa, com fonte completa, versão/hash do pacote, ações de edição e capturas dos diagnósticos. Confrontar, se houver registro, com o texto realmente inserido pelo participante.

13. **P13 — prioridade 2** — [capitulos/verificacao-complementar.tex:72](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/verificacao-complementar.tex). executar cargo llvm-cov e registrar versão da ferramenta, comandos, escopo, linhas e ramos cobertos no motor Rust; conservar o relatório para permitir conferência. A cobertura Flutter já foi obtida nesta revisão.

14. **P14 — prioridade 2** — [capitulos/verificacao-complementar.tex:159](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/verificacao-complementar.tex). realizar e preencher as medições do motor e do APK conforme o protocolo; registrar aparelho, compilação, versões, hash, ferramentas e dados das repetições. Validar os procedimentos propostos antes de executar e não substituir os campos vazios por estimativas de desempenho.

15. **P15 — prioridade 2** — [capitulos/verificacao-complementar.tex:176](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/verificacao-complementar.tex). informar a tag de entrega correspondente ao commit 47ea64a e a forma de acesso da banca ao repositório privado; confirmar se será disponibilizado um arquivo ou espelho institucional. Não foi criada ou presumida uma tag nesta revisão.

16. **P16 — prioridade 2** — [trabalho.tex:369](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: programa comparativo em C no gcc; registrar versão, comando e mensagem integral.

17. **P17 — prioridade 2** — [trabalho.tex:373](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: mesmo erro de nome no programa Lumi no Luminthor; registrar versão e hash do APK.

18. **P18 — prioridade 2** — [trabalho.tex:684](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). A3: fornecer, se disponível, tabela da PNAD com posse de microcomputador por faixa de renda e identificação da tabela e da população de referência.

19. **P19 — prioridade 2** — [trabalho.tex:1261](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). instalar e testar Portugol Mobile e Portugol WebStudio no celular; registrar versões, aparelho e capturas; anotar execução sem conexão, depuração passo a passo, mensagens de erro em português e visualização de memória.

20. **P20 — prioridade 2** — [trabalho.tex:1433](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). confirmar os diferenciais após os testes de Portugol Mobile e Portugol WebStudio; revisar especialmente rastro por escopo, exposição de tokens e AST e articulação da trilha com o editor. Não classificar células NC como recursos ausentes para sustentar originalidade.

21. **P21 — prioridade 2** — [trabalho.tex:1554](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar os demais ciclos, com datas, entregas e evidências, e fornecer os logs completos dos testes de 11/11/2026.

22. **P22 — prioridade 2** — [trabalho.tex:2088](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: Home com criação, importação e arquivos recentes; usar dados de demonstração e identificar o APK.

23. **P23 — prioridade 2** — [trabalho.tex:2136](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). A13: informar o Android mínimo lido do APK identificado e as medições de memória, armazenamento e desempenho; os valores antes propostos de Android 10, 3 GB de RAM e 200 MB não foram tratados como requisitos verificados.

24. **P24 — prioridade 2** — [trabalho.tex:2464](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: mapa da Trilha Lumi com módulos, etapas e indicação de progresso; identificar o APK.

25. **P25 — prioridade 2** — [trabalho.tex:2473](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: uma aula da Trilha Lumi com explicação, exemplo e ação de prática no editor; informar o título da aula e o APK.

26. **P26 — prioridade 2** — [trabalho.tex:2504](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: editor com teclado virtual aberto, numeração de linhas e barra de símbolos; identificar aparelho, Android e APK.

27. **P27 — prioridade 2** — [trabalho.tex:2534](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: lista de autocompletar para um prefixo digitado e símbolos visíveis no escopo; registrar o programa e o APK.

28. **P28 — prioridade 2** — [trabalho.tex:2637](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: diagnóstico léxico provocado por caractere inválido, por exemplo @ fora de texto ou comentário; preservar programa e mensagem exata.

29. **P29 — prioridade 2** — [trabalho.tex:2646](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: diagnóstico sintático de print(1; sem parêntese de fechamento; preservar programa e mensagem exata.

30. **P30 — prioridade 2** — [trabalho.tex:2655](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: declarar var pontos = 8; e executar print(pntos); mostrar o diagnóstico semântico e a sugestão realmente exibida.

31. **P31 — prioridade 2** — [trabalho.tex:2664](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: erro de execução com var divisor = 0; print(1 / divisor); registrar mensagem, passos disponíveis e versão do APK.

32. **P32 — prioridade 2** — [trabalho.tex:2673](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: aba Tokens para var x = 0; x = 3 + 5 * 2; com categorias, lexemas e posições legíveis.

33. **P33 — prioridade 2** — [trabalho.tex:2682](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: aba AST para o mesmo programa da captura de tokens, com o nó da atribuição expandido e seus operadores visíveis.

34. **P34 — prioridade 2** — [trabalho.tex:2716](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Captura: depurador em uma chamada de função, com passo selecionado, variáveis separadas por escopo, pilha de chamadas e saída; fornecer o programa correspondente.

35. **P35 — prioridade 3** — [capitulos/decisoes-tecnologicas.tex:43](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/decisoes-tecnologicas.tex). validar as justificativas das decisões tecnológicas reconstruídas no quadro; informar os critérios originalmente utilizados e eventuais alternativas de fato prototipadas, sem transformar a comparação qualitativa em resultado de desempenho.

36. **P36 — prioridade 3** — [capitulos/especificacao-lumi.tex:158](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/especificacao-lumi.tex). justificar as decisões da linguagem: intervalo de zero a N menos um no for, precedência de not, aceitação de comparações encadeadas, const sem inicializador, separadores opcionais e ausência de leitura de entrada e vetores. Confirmar quais comportamentos serão mantidos como decisões e quais serão tratados como limitações.

37. **P37 — prioridade 3** — [trabalho.tex:144](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). confirmar com o orientador o modelo da folha de aprovação, o texto de aprovação, a data e a composição da banca, com nomes, titulações, instituições e assinaturas. Esta folha é um modelo sem registro de aprovação.

38. **P38 — prioridade 3** — [trabalho.tex:521](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). escolher título. O título atual foi mantido na capa e na folha de rosto; as alternativas abaixo descrevem o artefato implementado.

39. **P39 — prioridade 3** — [trabalho.tex:1173](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). informar o protocolo de busca originalmente utilizado ou aprovar o protocolo complementar proposto; executar e registrar as consultas antes de apresentá-lo como procedimento concluído. As bases enumeradas acima são uma proposta, não um histórico de buscas já realizadas.

40. **P40 — prioridade 3** — [trabalho.tex:1601](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). validar a lista de RF e RNF, seu escopo e os critérios de aceitação; confirmar se há requisitos originalmente definidos que não aparecem nesta reconstrução.

41. **P41 — prioridade 3** — [trabalho.tex:1955](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). traduzir no aplicativo ``Execute'', ``Trace'', ``Settings'' e ``Templates'' ou justificar.

42. **P42 — prioridade 4** — [apendices/protocolo-observacao.tex:150](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/protocolo-observacao.tex). selecionar e citar uma versão validada da SUS em português, preservando seus dez itens e instruções; validar a versão e o roteiro com o orientador antes de eventual coleta.

## Verificações de fontes ou dados

1. **V01 — prioridade 1** — [trabalho.tex:3011](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). J4: conferir na exportação original o cruzamento de experiência com U01, U04 e U06. A atribuição às duas pessoas iniciantes consta do registro analítico original, mas o resumo público contém apenas distribuições marginais e não permite reproduzir esse cruzamento de forma independente.

2. **V02 — prioridade 2** — [trabalho.tex:1370](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). G4: conferir por versão as células NC do quadro comparativo; ausência de documentação não equivale a ausência do recurso. Verificar especialmente idioma dos diagnósticos, depuração e inspeção de estado nas ferramentas móveis.

3. **V03 — prioridade 3** — [referencias.bib:54](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M2: confirmar a numeração da edição de FIE 2020 e o local editorial dos anais; o site oficial confirma Uppsala e a realização on-line.

4. **V04 — prioridade 3** — [referencias.bib:82](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M2: confirmar o local editorial dos anais de ICCSE 2013; Colombo é o local do evento, confirmado no registro institucional de um dos autores.

5. **V05 — prioridade 3** — [referencias.bib:120](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M2: confirmar na fonte editorial o local do DASC 2014

6. **V06 — prioridade 3** — [referencias.bib:123](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M2: confirmar o local editorial dos anais do DASC 2014.

7. **V07 — prioridade 3** — [referencias.bib:158](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M3: confirmar os metadados e o endereço no registro SOL da SBC; a página não respondeu nesta revisão. O PDF consultado identifica o XXII WEI.

8. **V08 — prioridade 3** — [referencias.bib:175](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M2: confirmar se o registro editorial informa número de edição do SPLASH 2014; não inferido do ano.

9. **V09 — prioridade 3** — [referencias.bib:203](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). A5: a entrada por Gwendo e Chepkwony segue a correção solicitada pelo autor do TCC; o registro Crossref do DOI indexa os sobrenomes como Oloo e Robert. Confirmar a forma de entrada com os autores ou com o periódico.

10. **V10 — prioridade 3** — [referencias.bib:221](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). M2: confirmar no registro editorial da SBC o local e a editora dos anais estendidos de 2025; o PDF consultado confirma título, autores, páginas e DOI.

11. **V11 — prioridade 3** — [referencias.bib:476](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). G1: confirmar a ordem de autoria: o PDF apresenta Danilo antes de Douglas; a página do periódico e o Crossref apresentam Douglas antes de Danilo. Os três nomes foram conferidos.

12. **V12 — prioridade 3** — [referencias.bib:519](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). F5: conferir paginação e identificador do capítulo na edição de Brooke (1996) utilizada; o manuscrito da SUS foi consultado, mas a página da editora não pôde ser acessada. Não foram preenchidos números de página ou DOI sem essa conferência.

13. **V13 — prioridade 3** — [referencias.bib:552](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib). F6: confirmar a paginação completa da tradução inglesa de Levenshtein (1966); o texto indexado da página 707 foi conferido, mas o PDF integral não ficou acessível.

14. **V14 — prioridade 3** — [trabalho.tex:564](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). E1: confirmar o termo em fonte brasileira da Teoria da Carga Cognitiva; esta versão adota provisoriamente ``carga germânica'' para \textit{germane load}.

15. **V15 — prioridade 3** — [trabalho.tex:647](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). A1: conferir no texto integral de Bennedsen e Caspersen (2019) a definição do indicador de 28\% e a interpretação comparativa; autoria, título, periódico, volume, número, páginas e identificador digital de objeto (DOI, do inglês \textit{Digital Object Identifier}) foram confirmados.

16. **V16 — prioridade 3** — [trabalho.tex:811](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). F6: conferir os trechos e a edição efetivamente utilizada de Louden (2004) e Cooper e Torczon (2012); os metadados foram localizados em catálogos, mas os volumes integrais não foram consultados nesta revisão. A descrição técnica desta seção foi apoiada em Aho et al. (2007) e Nystrom (2021).

17. **V17 — prioridade 3** — [trabalho.tex:1319](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). A8: conferir em documentação específica ou teste direto se há depuração visual passo a passo na versão do Pocket Code comparada; esse recurso não foi confirmado na demonstração de 2014.

18. **V18 — prioridade 3** — [trabalho.tex:1457](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). H1: conferir no volume de Wazlawick (2021) os trechos utilizados para os eixos de classificação; a edição foi conferida no catálogo da editora, mas o texto integral não foi consultado nesta revisão. Gil (2002, cap. 4) foi consultado.

19. **V19 — prioridade 3** — [trabalho.tex:1922](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Guo (2018): revisar a aplicação dos resultados ao contexto de iniciantes brasileiros; o estudo não avalia a Lumi.

20. **V20 — prioridade 3** — [trabalho.tex:1930](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Dasgupta e Hill (2017): revisar a aplicabilidade de resultados de programação por blocos à linguagem textual Lumi.

21. **V21 — prioridade 3** — [trabalho.tex:1937](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex). Hermans (2020): revisar a relação entre a progressão sintática da Hedy e a justificativa de transferência adotada para a Lumi.

## Alterações do inventário nesta fase

### Autor

- Inserido ou reformulado: `\autor{confirmar com o orientador o modelo da folha de aprovação, o texto de aprovação, a data e a composição da banca, com nomes, titulações, instituições e assinaturas. Esta folha é um modelo sem registro de aprovação.}`
- Retirado ou substituído: `\autor{definir se haverá nova coleta com iniciantes para o objetivo f; a redação atual corresponde à avaliação exploratória disponível. As duas alternativas abaixo ficam para decisão do autor.}`

### Verificar

- Inserido ou reformulado: `\verificar{E1: confirmar o termo em fonte brasileira da Teoria da Carga Cognitiva; esta versão adota provisoriamente ``carga germânica'' para \textit{germane load}.}`
- Inserido ou reformulado: `\verificar{A1: conferir no texto integral de Bennedsen e Caspersen (2019) a definição do indicador de 28\% e a interpretação comparativa; autoria, título, periódico, volume, número, páginas e identificador digital de objeto (DOI, do inglês \textit{Digital Object Identifier}) foram confirmados.}`
- Inserido ou reformulado: `\verificar{M2: confirmar a numeração da edição de FIE 2020 e o local editorial dos anais; o site oficial confirma Uppsala e a realização on-line.}`
- Inserido ou reformulado: `\verificar{M2: confirmar o local editorial dos anais de ICCSE 2013; Colombo é o local do evento, confirmado no registro institucional de um dos autores.}`
- Inserido ou reformulado: `\verificar{M2: confirmar na fonte editorial o local do DASC 2014}`
- Inserido ou reformulado: `\verificar{M2: confirmar o local editorial dos anais do DASC 2014.}`
- Inserido ou reformulado: `\verificar{M3: confirmar os metadados e o endereço no registro SOL da SBC; a página não respondeu nesta revisão. O PDF consultado identifica o XXII WEI.}`
- Inserido ou reformulado: `\verificar{M2: confirmar se o registro editorial informa número de edição do SPLASH 2014; não inferido do ano.}`
- Inserido ou reformulado: `\verificar{M2: confirmar no registro editorial da SBC o local e a editora dos anais estendidos de 2025; o PDF consultado confirma título, autores, páginas e DOI.}`
- Retirado ou substituído: `\verificar{A1: conferir no texto integral de Bennedsen e Caspersen (2019) a definição do indicador de 28\% e a interpretação comparativa; autoria, título, periódico, volume, número, páginas e DOI foram confirmados.}`

A alternativa de nova coleta foi retirada dos objetivos porque o autor escolheu mantê-la como proposta futura. O marcador A1 recebeu somente a expansão de DOI; sua verificação continua pendente. A nova folha de aprovação acrescentou uma pendência institucional.
