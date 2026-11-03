# Guia da avaliação curta — LUMI-AV02

Versão de 28/10/2026. Reservado ao pesquisador; não enviar aos participantes.

## O que foi simplificado

O formulário passou de 67 para **13 perguntas**, sendo duas opcionais. Contém três atividades guiadas, quatro afirmações de percepção e uma pergunta de comentário. A estimativa inicial é de 10 a 15 minutos além da instalação; confirme essa duração no piloto.

Foram retirados cronômetro, contagem de tentativas, número de erros corrigidos, código escrito do zero, colagem da solução e perguntas repetidas por tarefa. Não exigir essas informações por fora: isso aumentaria novamente o esforço dos participantes.

A atividade 5 testa execução; a 6, consulta ao depurador; e a 7, compreensão de um diagnóstico. A avaliação passa a ser exploratória e mais restrita que o protocolo original de cinco tarefas. Não apresentar essa versão como execução integral daquele protocolo.

## Antes de enviar

1. Preencha seu contato no formulário e copie o documento para a plataforma escolhida.
2. Configure Q1: recusa ou idade inferior a 18 encerra a participação sem apresentar as demais perguntas. A pessoa também pode fechar sem enviar.
3. Configure Q3: quem não conseguiu abrir o app vai diretamente à Q13, sem precisar responder às tarefas ou escalas.
4. Deixe Q4 e Q13 opcionais. Nas Q5/Q6 aceite “Não consegui”; na Q7 aceite “Não entendi” ou relato de tentativa. Não obrigue uma resposta certa. Deixe Q5 a Q8 opcionais se isso for necessário para permitir interrupção; em Q9 a Q12 ofereça “Não consegui avaliar”.
5. Não embaralhe perguntas. Não mostre gabaritos nem as respostas de outras pessoas. Desative a coleta de nome/e-mail e verifique o comportamento de login da plataforma. Se houver identificação coletada, explique isso corretamente na apresentação.
6. Envie a mesma versão do APK a todos e registre arquivo, versão, código-fonte e hash. Use a identificação LUMI-AV02 para essa coleta.
7. Faça um piloto com uma pessoa usando o APK de distribuição. Confira cópia dos exemplos, localização dos controles, legibilidade e duração. Registre mudanças feitas depois do piloto e separe seus dados quando o instrumento mudar.

O arquivo Word é um documento editável. Os saltos precisam ser configurados na plataforma; não estão automatizados no documento.

## Gabarito das três atividades

### Q5 — Execução

Saída esperada: **10**. Aceite 10 ou um relato equivalente do número mostrado. “Não consegui” é dificuldade relatada; campo vazio é dado ausente. Uma resposta correta é compatível com o programa, mas não comprova isoladamente a execução no telefone.

### Q6 — Depurador

No segundo passo, depois de `numero = numero + 3;`, o valor esperado é **5**. O programa tem quatro passos no motor verificado. O valor 10 corresponde ao estado posterior, não ao passo solicitado. Apresente a quantidade de respostas corretas e as dificuldades, sem inferir ganho de aprendizagem.

### Q7 — Mensagem de erro

O programa declara `pontos`, mas tenta imprimir `pntos`. O diagnóstico deve indicar o nome não declarado e pode sugerir `pontos`. Correção de referência: `print(pontos);`, produzindo **8**. Também é válida outra alteração que torne declaração e uso consistentes.

Classifique a resposta aberta, aceitando linguagem cotidiana:

- **2 — Compreensão completa:** identifica a diferença no nome e uma alteração adequada.
- **1 — Compreensão parcial:** identifica apenas o problema ou apenas uma alteração adequada.
- **0 — Não compreendeu:** tentou a atividade, mas não identifica nenhum dos dois aspectos, inclusive quando informa que não entendeu.
- **Não avaliável:** não realizou a atividade, não viu a mensagem ou deixou o campo vazio sem informação suficiente.

O formulário não pede o código final nem a saída depois da correção. Portanto, essa pontuação avalia compreensão relatada e plausibilidade da ação, e não conclusão prática verificada da correção.

## Como analisar sem complicar

- Informe quantas respostas consentidas recebeu e quantas pessoas conseguiram instalar/abrir. Em Q3, “outro motivo” não deve ser contado automaticamente como defeito do aplicativo.
- Separe iniciantes e pessoas experientes usando Q2. A categoria “Nunca programei” também deve aparecer na descrição da amostra.
- Para Q5 e Q6, apresente contagens de respostas compatíveis com o gabarito, incorretas, “Não consegui” e ausentes, com os denominadores. Não transformar campo vazio em erro automaticamente.
- Para Q7, apresente a distribuição 0/1/2 e não avaliável. Se usar percentual de compreensão completa, informe que o denominador são as respostas avaliáveis e mostre também as exclusões.
- Use Q8 para contextualizar ajuda recebida. Ela é uma informação geral da sessão; não permite classificar cada atividade como realizada sem auxílio.
- Para Q9 a Q12, apresente frequências ou mediana por item e número de respostas válidas. “Não consegui avaliar” fica fora da escala de 1 a 5. Não é nota 0 nem nota 3.
- Agrupe os comentários de Q13 por temas, como instalação, controles, mensagens e depurador. Não generalize uma ausência de comentário como ausência de problema.
- Não calcule nota SUS, ganho de aprendizagem, tempo de execução ou taxa de conclusão sem auxílio por tarefa: esses indicadores não são medidos nesta versão.

A planilha `registro-respostas.csv` está vazia e contém os campos do formulário, mais colunas de classificação para você preencher. Use um identificador interno de linha, como R001, sem acrescentar uma pergunta de código ao participante. Preserve a exportação original da plataforma.

## Ajuste necessário no TCC

Antes de coletar, alinhe com o orientador a redução do instrumento. A seção atual do trabalho.tex prevê cinco tarefas, oito afirmações, tempos e contagens. A versão curta substitui esse desenho por três atividades guiadas e quatro afirmações. Também muda o foco para **usabilidade percebida, uso inicial do depurador e compreensão de um diagnóstico semântico**.

Atualize o protocolo e o objetivo que menciona eficácia pedagógica para refletir o que será efetivamente medido. Retire os limiares de 80% das tarefas sem auxílio e de 75% para três mensagens, pois os dados necessários para esses critérios não são coletados aqui. Não misture respostas desta versão com as da LUMI-AV01 como se os instrumentos fossem iguais.

Texto sugerido para o planejamento, sem afirmar coleta já realizada:

> Será conduzida uma avaliação exploratória remota, com distribuição do APK e de um formulário breve. Os participantes realizarão três atividades guiadas: executar um programa, consultar o valor de uma variável em um passo do depurador e interpretar um diagnóstico semântico para tentar uma correção. Serão coletados relatos de instalação, respostas às atividades, informação geral de ajuda externa, quatro itens de percepção em escala de cinco pontos e um comentário opcional. As respostas serão analisadas por contagens, estatística descritiva e categorização dos comentários. O estudo avaliará usabilidade percebida e compreensão do diagnóstico apresentado, sem medir ganho de aprendizagem ou desempenho móvel.

Depois da aplicação, escreva o que realmente ocorreu, com amostra efetiva e resultados. A monografia não foi alterada nesta preparação.

## Convite curto para enviar junto com o APK

Olá! Você pode me ajudar a testar o Luminthor, aplicativo do meu TCC? São três atividades rápidas e um formulário com 13 perguntas, com duração estimada de 10 a 15 minutos, além da instalação. Não precisa saber programar. A participação é voluntária, para maiores de 18 anos. Se não conseguir instalar ou usar alguma função, seu relato também ajuda.

APK: [ARQUIVO OU LINK]
Formulário: [LINK]
Prazo: [DATA]

Obrigado!

## Verificação dos exemplos

Os exemplos devem ser conferidos também no APK do piloto. O arquivo `validacao-exercicios.json` registra a verificação na CLI nativa preexistente, sem nova compilação e sem afirmar validação do APK.
