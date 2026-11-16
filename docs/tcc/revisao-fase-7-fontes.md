# Fontes, dados e alcance da conferência — Fase 7

Data: 15/11/2026. Não foram acrescentadas referências bibliográficas. A revisão
usa os agregados já preservados, os registros técnicos da Fase 6 e a reprodução
específica de T3. Não houve novos participantes ou ensaios Android físicos.

| Item | Fonte e conferência | Limite |
| --- | --- | --- |
| J1 | [Logs e cobertura da Fase 6](evidencias-fase-6/README.md): 68 Rust, 159 Flutter; analyze sem problemas; LCOV com 3.764/4.569 linhas e recorte sem bindings com 3.548/3.917 | Refere-se a Linux e código `95d3cdd`; não identifica APK ou medições físicas |
| J2–J3 | Quatro quadros da Fase 6 e `docs/avaliacao-luminthor/resultados/resumo-2026-11-14.json` | Frequências e medianas mantidas; percentuais da pequena amostra foram apresentados como contagens e denominadores |
| J4 | Afirmação presente no texto anterior e no roteiro de revisão: neutras em U01/U04/U06 atribuídas aos dois usuários com menos de três meses | O JSON público contém somente distribuições marginais; não permite conferir associação individual. Novo marcador de verificação na fonte original |
| J5 | README e JSON da avaliação: quatro respostas A01, três A02, quatro pessoas com comentário | Os textos integrais não estão disponíveis; tabela preparada, sem reconstrução de falas. Removido uso de excerto isolado como substituto da transcrição |
| J6 | [Programa auxiliar, retornos e logs](evidencias-fase-7/README.md), cinco cenários por revisão | Demonstra o comportamento do motor para fontes explícitas; não reproduz a digitação do participante ou seu APK |
| J7–J9 | Capítulos 2–3, resultados e matriz de evidências com referências de página | Discussão contextual; não há comparação controlada, medida de carga cognitiva ou de aprendizagem |
| J10 | Protocolo futuro proposto e decisão do autor de mantê-lo como proposta futura | Não houve recrutamento ou coleta; versão validada da SUS em português ainda deve ser selecionada antes de eventual aplicação |

A exportação original da avaliação é identificada no resumo por SHA-256
`a445e1595e352b67a2240a0ae5715ec7cbc77fa68ad37188311f16c7ad396917`.
Esse identificador é da planilha, não do APK. A planilha permanece com o pesquisador,
fora do repositório; nomes, e-mails e comentários integrais não foram copiados.

## Literatura utilizada na discussão

- [Becker (2016), artigo do autor no repositório UCD](https://researchrepository.ucd.ie/bitstreams/963ffee9-e781-4371-8856-0f4df89d127b/download): resumo e conclusão consultados; contexto Java e avaliação por erros. Não se transferiram seus resultados ao Luminthor.
- [Denny, Luxton-Reilly e Carpenter (2014), registro do autor](https://www.cs.auckland.ac.nz/~andrew/publications.html) e [artigo utilizado na Fase 4](https://www.cs.auckland.ac.nz/courses/compsci747s2c/lectures/errors.pdf): manteve-se a contextualização já conferida na fundamentação. A nova abertura direta do PDF nesta fase não respondeu; não foram adicionados números ou detalhes novos a partir dessa tentativa.
- [Sorva, Karavirta e Malmi (2013), registro dos autores](https://research.aalto.fi/en/publications/a-review-of-generic-program-visualization-systems-for-introductor/) e [cópia do artigo consultada](https://romisatriawahono.net/lecture/rm/survey/software%20engineering/Software%20Architecture/Sorva%20-%20Generic%20Program%20Visualization%20Systems%20for%20Introductory%20Programming%20-%202013.pdf): resumo e seções sobre envolvimento e continuidade da pesquisa. A discussão distingue disponibilizar estados de observar sua interpretação.
- Sweller (1988), Sweller/van Merriënboer/Paas (1998) e os dois Marceau (2011), já referenciados no Capítulo 2: usados como referenciais para interpretar dificuldades e delimitar hipóteses. O levantamento não mediu carga cognitiva ou todas as etapas de correção.
- [Brooke (1996), manuscrito original da SUS](https://hci-studies.org/methods-and-measures/downloads/SUS_Brooke1996.pdf): uso após interação e cálculo conferidos. A escala proposta não foi aplicada e não substitui retroativamente o instrumento de oito itens.

## Reprodução de T3

A revisão histórica foi extraída do Git local; o ensaio atual usa a fonte do
projeto. Ambos foram compilados com o Cargo.lock correspondente e dependências
locais. Cada programa auxiliar chama a API cinco vezes no mesmo processo:
T2 inválida, substituição integral por T3, concatenação T2/T3, controle T2 corrigida
e substituição do controle por T3.

A substituição produziu divisão por zero; a concatenação preservou o erro de
parêntese da T2, antes da interpretação. A hipótese de texto remanescente é
plausível nesse cenário, sem confirmar a causa do relato original. Continua
pendente a reprodução das ações de edição no APK identificado.

O script de reprodução entregue foi executado e confirmou os cinco cenários
nas duas revisões. Não houve alteração de fonte de `lib/`, `rust_core/` ou `test/`.
Os testes completos da Fase 6 não foram novamente executados nesta fase, pois
não houve mudança no aplicativo; os novos ensaios tratam especificamente de J6.
