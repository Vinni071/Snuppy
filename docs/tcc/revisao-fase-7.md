# Revisão do TCC Luminthor — Fase 7

Data: 15/11/2026. Escopo: resultados e discussão, itens J1–J10. A fase foi
concluída com os documentos e ensaios ausentes explicitados. Por decisão do autor,
a nova coleta foi mantida como **proposta futura**, sem recrutamento ou agendamento.
A Fase 8 aguarda novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Resultados técnicos complementares](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/resultados-tecnicos-complementares.tex).
- [Reprodução do caso T3](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/reproducao-t3.tex).
- [Modelo para comentários integrais](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/comentarios-integrais.tex).
- [Discussão e matriz de evidências](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/discussao-resultados.tex).
- [Apêndice E: proposta futura](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/protocolo-observacao.tex).
- [Verificação do Desenvolvimento, com remissão atualizada](../../TCC_Teorico/Projeto_LaTeX_TCC/capitulos/verificacao-complementar.tex).
- [Diff unificado em relação à Fase 6](revisao-fase-7.patch).
- [Pacote dos fontes e evidências](../../output/tcc/Luminthor_Revisao_Fase_7_Fontes.zip).
- [PDF compilado](../../output/pdf/Luminthor_Revisao_Fase_7.pdf).
- [Fontes e limites da conferência](revisao-fase-7-fontes.md).
- [Reprodução técnica e logs](evidencias-fase-7/README.md).
- [Validação documental e dos dados](../../output/tcc/Luminthor_Revisao_Fase_7_Validacao.json).

Foram acrescentados cinco arquivos LaTeX e alterados o principal e uma remissão
no Desenvolvimento. A bibliografia, os manuais e o pacote institucional não
foram alterados. O ZIP reúne os fontes necessários para compilar o TCC, os
registros técnicos das Fases 6–7 e os agregados públicos e script da análise.
Não contém a planilha original com identificadores pessoais ou APK. O PDF
na pasta do projeto é idêntico ao PDF entregue.

Compilar na pasta `TCC_Teorico/Projeto_LaTeX_TCC`:

```sh
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

Para reproduzir T3, na raiz do repositório, com Git, Cargo, Python 3.12+ e as
dependências disponíveis no cache:

```sh
python3 docs/tcc/evidencias-fase-7/reproduzir-t3.py --output /tmp/tcc-t3
```

## 2. Registro de mudanças

| ID | Arquivo/local | Mudança e alcance |
| --- | --- | --- |
| J1 | Resultados, 6.1.1; Tabela 4 | Acrescentados os resultados atuais de 68 Rust, 159 Flutter, analyze sem problemas e cobertura Dart. Contagens históricas de 11/11 permaneceram separadas; medições I13 e cobertura Rust continuam pendentes |
| J1 | Nova 6.1.2; Tabela 5 | Tabela vazia e procedimento para dois ou três aparelhos, um de entrada, com identificação do APK e verificações de instalação, rede, persistência, arquivos e teclado |
| J2 | `trabalho.tex`; Tabelas 3, 6, 7 e 8 | Quatro quadros numéricos convertidos em tabelas sem bordas laterais, com linhas de booktabs. Rótulos `quad:` migraram para `tab:` e remissões foram atualizadas; Lista de Tabelas alimentada automaticamente |
| J3 | Participantes, tarefas, escala; referências no resumo e conclusão | Percentuais da amostra pequena substituídos por contagens com denominador, como 6 de 8. Frequências e medianas preservadas. Percentuais da cobertura de milhares de linhas e indicadores externos não foram alterados |
| J4 | 6.2.4, parágrafo destacado | Discutido o sinal menos favorável dos dois iniciantes em U01/U04/U06, com marcador explícito para conferir o cruzamento na exportação original. As marginais públicas não foram usadas para fabricar dados individuais |
| J5 | 6.2.5; Tabela 9 | Reservada transcrição por campo e código anônimo, sem preencher falas ausentes. Contagens de quatro A01, três A02 e quatro pessoas mantidas. Um excerto isolado deixou de servir como substituto da transcrição integral |
| J6 | Nova 6.2.3; Quadro 14 | Cinco cenários executados em cada revisão do motor, histórica e atual. Substituição integral leva a divisão por zero; concatenação mantém erro sintático. Hipótese plausível, sem confirmar causa do relato ou reproduzir a interação no APK |
| J7 | Nova 6.3.1–6.3.3 | Discussão relaciona mensagens e autonomia a Marceau/Denny/Becker, rastro e interpretação a Sorva, interação e nomenclatura à carga cognitiva; compara o alcance com os trabalhos relacionados sem alegar superioridade |
| J8 | Nova 6.4; Quadro 16 | Matriz de sete afirmações centrais com demonstração técnica, relato, pendência e referências de página. Incluídos limites de escopo e de aprendizagem |
| J9 | Nova 6.5 | Contribuição tecnológica explicitada, alcance científico restrito e contribuição educacional mantida como hipótese |
| J10 | Novo Apêndice E | Protocolo futuro com cinco a oito iniciantes, modalidade de observação, critérios de tarefas, tempo, ajuda e SUS. Tabelas 10–11 vazias. Decisão de manter como proposta futura respeitada; versão validada da SUS em português permanece para selecionar |
| Preservação | Resultados e Desenvolvimento | Conteúdo do quadro de temas preservado literalmente; quatro tabelas conferidas célula a célula, normalizando apenas a representação das proporções. Bloco técnico 5.3.1–5.3.4 e Código 1 preservados |

### Resultado da reprodução de T3

O programa auxiliar faz chamadas sucessivas no mesmo processo. Foram confirmados
os cinco cenários nas revisões `1ff10f8` e `95d3cdd`:

| Cenário | Resultado nas duas revisões |
| --- | --- |
| T2 inválida | Erro de parêntese; sem AST e sem rastro |
| T3 substitui todo o texto da T2 inválida | Divisão por zero; dois eventos anteriores à falha |
| T3 é acrescentada à T2 inválida mantida | Permanece o erro de parêntese; interpretação não iniciada |
| T2 corrigida, como controle | Saída 15 |
| T3 substitui o controle corrigido | Divisão por zero; dois eventos anteriores à falha |

A concatenação demonstra uma condição possível, sem provar que ela ocorreu na
coleta. Não houve ensaio de digitação ou substituição no APK do participante.
O script de reprodução entregue também foi executado, com resultados compatíveis.
Nenhum fonte do aplicativo foi alterado; as suítes completas da Fase 6 não foram
reexecutadas sem necessidade. Os ensaios novos foram os específicos de J6.

### Validação e preservação dos dados

O PDF tem **138 páginas**, com compilação sem erros, referências
indefinidas, rótulos duplicados ou caixas excedentes (`Overfull`). Foram renderizadas
e inspecionadas 32 páginas, incluindo as tabelas de resultados,
a matriz e o protocolo futuro. Há 19 figuras, um gráfico, 16 quadros, 11 tabelas
e cinco códigos. A bibliografia conserva 59 entradas e 58 utilizadas.

A conferência das quatro tabelas comparou todas as células anteriores e atuais,
retirando apenas a notação percentual antiga e os denominadores textuais novos.
Assim, preservou contagens, distribuições 1–5, medianas e conteúdo dos relatos
resumidos. As distribuições e medianas também foram confrontadas com o JSON público.
Não foi reconstruído o cruzamento individual entre experiência e respostas neutras.

| Rótulo anterior | Tipo/número na Fase 6 | Rótulo e número atual |
| --- | --- | --- |
| `quad:validacao_tecnica` | Quadro 14 | `tab:validacao_tecnica`, Tabela 3 |
| `quad:perfil_participantes` | Quadro 15 | `tab:perfil_participantes`, Tabela 6 |
| `quad:respostas_tarefas` | Quadro 16 | `tab:respostas_tarefas`, Tabela 7 |
| `quad:usabilidade_participantes` | Quadro 17 | `tab:usabilidade_participantes`, Tabela 8 |
| `quad:temas_comentarios` | Quadro 18 | Quadro 15; conteúdo literal idêntico |

As tabelas de aparelho, comentários integrais, tarefas futuras e SUS foram
conferidas para permanecer sem resultados preenchidos. N01–N08 são vagas
reservadas, não novos participantes. As duas tabelas de medições do Desenvolvimento
continuam pendentes. As 14 capturas permanecem sem preenchimento fictício.

O bloco técnico protegido e o Código 1 têm os mesmos hashes da Fase 6. Os fontes
entregues conferem com os compilados; o diff passou por aplicação simulada contra
o snapshot da fase anterior. O ZIP foi conferido por CRC e comparação de conteúdo.

## 3. Todos os novos marcadores `\autor{}`

1. `\autor{selecionar e citar uma versão validada da SUS em português, preservando seus dez itens e instruções; validar a versão e o roteiro com o orientador antes de eventual coleta.}`

2. `\autor{fornecer os textos completos de A01 e A02, com códigos estáveis de participante e indicação do campo, sem nomes, e-mails ou outros identificadores. Preservar a redação e sinalizar eventuais supressões de dados pessoais; não reconstruir falas a partir das categorias resumidas.}`

3. `\autor{reproduzir no APK e no aparelho a sequência de T2 sem correção seguida de T3; registrar separadamente substituir todo o texto e acrescentar o novo programa, com fonte completa, versão/hash do pacote, ações de edição e capturas dos diagnósticos. Confrontar, se houver registro, com o texto realmente inserido pelo participante.}`

4. `\autor{realizar ensaio em dois ou três celulares, incluindo um de entrada; registrar modelo, categoria, Android, versão e hash SHA-256 do APK, data e responsável; verificar instalação, execução em modo avião, persistência após encerrar e reabrir, importação, exportação e interação com o teclado. Preencher a tabela e anexar as evidências, mantendo campos vazios enquanto o ensaio não for executado.}`

Há **4 novos marcadores**. No conjunto, permanecem 14 capturas e
28 outras pendências do autor. A nova coleta já foi definida como proposta
futura; não há nova pergunta para decidir sua execução nesta fase.

## 4. Todos os novos marcadores `\verificar{}`

1. `\verificar{J4: conferir na exportação original o cruzamento de experiência com U01, U04 e U06. A atribuição às duas pessoas iniciantes consta do registro analítico original, mas o resumo público contém apenas distribuições marginais e não permite reproduzir esse cruzamento de forma independente.}`

Há um novo marcador e 13 verificações pendentes no total. O ponto novo
é o cruzamento de experiência e notas neutras, que exige a exportação original.
A apresentação destacada foi mantida com atribuição ao registro analítico anterior,
sem alegar nova conferência individual.

## 5. Questões que bloqueiam a próxima fase

Nenhuma impede iniciar a Fase 8, sobre conclusão, resumo, Abstract, normas,
referências e tipografia, mediante novo “continue”. As pendências empíricas
permanecem visíveis e não serão resolvidas por suposição nessa etapa editorial.

Continuam necessários para completar os resultados: comentários integrais
anonimizáveis; fonte original para conferir o cruzamento dos iniciantes; ensaios
em aparelhos com APK identificado; reprodução das ações de edição de T3; medições
e cobertura Rust já solicitadas. O protocolo do Apêndice E permanece futuro,
conforme orientação do autor, sem coleta adicional iniciada.
