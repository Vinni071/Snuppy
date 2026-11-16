# Revisão do TCC Luminthor — Fase 8, final

Data: 15/11/2026. Escopo: K, E, L e M, com auditoria final A–M.
**Revisão editorial final concluída; documentação empírica e institucional ainda
pendente.** A nova coleta permanece apenas proposta futura, conforme decisão do autor.

## 1. Arquivos completos e diff

- [Fonte principal completo](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Pacote completo de fontes, relatórios e evidências](../../output/tcc/Luminthor_Revisao_Fase_8_Fontes.zip).
- [Diff unificado contra a Fase 7](revisao-fase-8.patch).
- [PDF final compilado](../../output/pdf/Luminthor_Revisao_Fase_8.pdf).
- [Validação, hashes e verificações](../../output/tcc/Luminthor_Revisao_Fase_8_Validacao.json).
- [Auditoria dos 112 itens A–M e critérios de pronto](revisao-fase-8-auditoria.md).
- [Todas as pendências, por prioridade](revisao-fase-8-pendencias.md).
- [Conferência das fontes](revisao-fase-8-fontes.md).
- [Procedência das fontes de ilustrações e tabelas](revisao-fase-8-procedencia.md).

Foram alterados 12 dos 22 arquivos do projeto LaTeX. O ZIP contém os fontes
completos, os relatórios anteriores necessários para acompanhar a auditoria,
os agregados públicos e as evidências das Fases 6–7. Não contém planilha com
identificadores, imagens fictícias, APK ou textos integrais de terceiros.
A cópia `trabalho.pdf` do projeto é idêntica ao PDF entregue.

Para compilar, na pasta `TCC_Teorico/Projeto_LaTeX_TCC`:

```sh
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

A compilação desta fase foi executada em cópia isolada, com os mesmos fontes,
para preservar os arquivos auxiliares locais. Foram mantidos os programas e
dados originais do aplicativo.

## 2. Registro de mudanças

| ID | Arquivo/local | O que mudou |
| --- | --- | --- |
| K1 | Conclusão, Quadro 17 | Oito objetivos, evidências e situações: cinco atingidos e três parcialmente atingidos; pendências de aparelho e persistência ligadas aos objetivos correspondentes |
| K2–K4 | Conclusão, 7.1–7.2 | Resposta à pergunta em um parágrafo; contribuições tecnológicas/documentais; um parágrafo de limitações com remissão às ameaças |
| K5 | Conclusão, 7.3 | Trabalhos futuros com validação pendente separada das extensões do produto e da pesquisa educacional |
| D5/J10 | Introdução, objetivos | Retirada a decisão ainda aberta sobre nova coleta; mantido o objetivo exploratório existente e a observação de iniciantes como proposta futura |
| E1–E2 | Texto, manuais e discussão | Removidas ressalvas genéricas repetidas; três núcleos principais, no resumo com tradução, nas ameaças e na conclusão; germane load por extenso e termo brasileiro marcado para conferir |
| E3–E4 | Texto e manuais | Padronizados depurador, motor, modelos de código, percurso e ligações; nomes de arquivos, rótulos de interface e o bloco literal protegido preservados |
| E5–E6 | Conferência de metodologia e Desenvolvimento | Códigos internos apresentados e quadro de componentes mantido; conteúdo protegido não foi reescrito para alterar nomes de classe |
| L1–L3 | Resumo e Abstract | Resumo com problema, FFI por extenso, método e resultados atuais, 286 palavras; tradução fiel em página própria, descritores com separadores e caixa corretos |
| L4 | Fonte principal e estilo | Títulos de nível 3 em caixa de frase e sem negrito; os quatro títulos técnicos protegidos são transformados somente na apresentação |
| L5–L6 | Listas | Siglas sem uso retiradas, APK/NDK/JDK/GTK e termos utilizados acrescentados; Σ corrigido para terminais; símbolos ordenados por primeira ocorrência matemática |
| L7–L8 | Estilo, texto e capítulos | Fonte uniformizada em “Fonte: O autor (2026).”; atribuições externas permanecem no texto. Notas anteriores de procedência registradas em arquivo próprio; diagramas e chamadas conferidos |
| L9 | Estilo e lista | Gráfico único integra a Lista de Ilustrações em ordem de ocorrência; 19 figuras e um gráfico cabem em uma página, com numerações próprias |
| L10 | Pré-textuais | Modelo de folha de aprovação após folha de rosto, sem aprovação, banca ou assinaturas presumidas |
| M1 | Bibliografia | Proteções de nomes, siglas e capitalização interna, inclusive no início dos títulos |
| M2 | Bibliografia | Oito registros de evento com nome, número quando confirmado, ano, local, publicação, editora e páginas; dados ausentes marcados |
| M3 | Bibliografia | Aho: 2. ed., Boston; editoras retiradas de artigos; SOL acrescentado; autoria e metadados ainda divergentes mantidos para verificar |
| M4 | Estilo e PDF | Ligaduras desativadas para fontes monoespaçadas; preservados -- nos comandos e >> no tipo Rust |

Nota ao autor sobre terminologia: **depurador** designa o recurso; **aba Trace**
identifica o rótulo atualmente existente. Usa-se **motor**, **Luminthor** para o
produto, **aplicativo** para a instalação e **modelos de código**. Nomes literais
como `templates`, `engine_test.dart` e termos dentro do bloco técnico protegido
foram conservados por serem identificadores ou por exigência de preservação.

### Validação e alcance da entrega

O PDF final tem **141 páginas**. A compilação terminou sem erros, referências
indefinidas, rótulos duplicados ou caixas excedentes. O registro contém avisos de
compatibilidade/depreciação dos pacotes instalados, sem impedir a geração.
Há **19 figuras, um gráfico, 17 quadros, 11 tabelas e cinco códigos**;
59 entradas bibliográficas cadastradas e 58 utilizadas.

Os 141 fólios foram renderizados para conferência do conjunto. Foram verificadas
em maior resolução páginas de pré-textuais, listas, código, matrizes, resultados,
conclusão, referências e apêndices. O quadro de objetivos cabe inteiro em uma
página, a conclusão termina sem o fragmento isolado que surgiu na primeira
compilação e a lista unificada permanece em uma página.

O bloco técnico original, o Código 1, as quatro tabelas numéricas e o quadro de
temas têm hashes idênticos aos da Fase 7. Os agregados e os registros técnicos
foram conferidos pelos hashes da entrega anterior. Não houve reconstrução de
respostas individuais, preenchimento de capturas ou execução de nova coleta.
As suítes do aplicativo não foram repetidas nesta fase editorial: os resultados
68 Rust/159 Flutter e a cobertura permanecem os efetivamente registrados na Fase 6.

A extração do PDF preserva `Vec<HashMap<String, Symbol>>`, `--offline`,
`--manifest-path`, `--no-pub`, `--reporter` e `--json`. O diff passou por
aplicação simulada contra o snapshot da Fase 7. Fontes compilados e entregues
são idênticos; o ZIP foi conferido por CRC e conteúdo.

Os **112 IDs** e os **11 critérios de pronto** estão avaliados individualmente na
[auditoria final](revisao-fase-8-auditoria.md). O critério dos documentos da coleta
é parcial: os Apêndices C/D reservam os originais ausentes. A conferência das
citações é condicionada às verificações explicitadas; não se declara acesso
integral às obras cujos trechos ou metadados permanecem marcados.

## 3. Todos os novos marcadores `\autor{}`

1. `\autor{confirmar com o orientador o modelo da folha de aprovação, o texto de aprovação, a data e a composição da banca, com nomes, titulações, instituições e assinaturas. Esta folha é um modelo sem registro de aprovação.}`

Foi inserido **um** marcador, na folha de aprovação. Foi retirado o marcador
sobre decidir a nova coleta, pois essa decisão já foi fornecida pelo autor.
Permanecem **42 pendências do autor**, sendo 14 capturas e 28 outras.
A [lista consolidada P01–P42](revisao-fase-8-pendencias.md) contém o texto integral
de cada marcador, sua localização e prioridade.

## 4. Todos os novos marcadores `\verificar{}`

1. `\verificar{E1: confirmar o termo em fonte brasileira da Teoria da Carga Cognitiva; esta versão adota provisoriamente ``carga germânica'' para \textit{germane load}.}`

2. `\verificar{A1: conferir no texto integral de Bennedsen e Caspersen (2019) a definição do indicador de 28\% e a interpretação comparativa; autoria, título, periódico, volume, número, páginas e identificador digital de objeto (DOI, do inglês \textit{Digital Object Identifier}) foram confirmados.}`

3. `\verificar{M2: confirmar a numeração da edição de FIE 2020 e o local editorial dos anais; o site oficial confirma Uppsala e a realização on-line.}`

4. `\verificar{M2: confirmar o local editorial dos anais de ICCSE 2013; Colombo é o local do evento, confirmado no registro institucional de um dos autores.}`

5. `\verificar{M2: confirmar na fonte editorial o local do DASC 2014}`

6. `\verificar{M2: confirmar o local editorial dos anais do DASC 2014.}`

7. `\verificar{M3: confirmar os metadados e o endereço no registro SOL da SBC; a página não respondeu nesta revisão. O PDF consultado identifica o XXII WEI.}`

8. `\verificar{M2: confirmar se o registro editorial informa número de edição do SPLASH 2014; não inferido do ano.}`

9. `\verificar{M2: confirmar no registro editorial da SBC o local e a editora dos anais estendidos de 2025; o PDF consultado confirma título, autores, páginas e DOI.}`

São **oito verificações novas** e **uma reformulação editorial do marcador A1**,
que apenas expandiu DOI. O total passou de 13 para **21 verificações pendentes**.
Os dados editoriais inacessíveis não foram preenchidos de memória; `[S.l.]` e
os marcadores identificam a falta de confirmação. A lista completa V01–V21
está no [inventário consolidado](revisao-fase-8-pendencias.md).

## 5. Questões que bloqueiam a próxima fase

Não há próxima fase: a Fase 8 encerra o roteiro autorizado. Não há pergunta
pendente para concluir esta entrega editorial.

Para a submissão definitiva, é necessário resolver as pendências consolidadas,
priorizando os originais do formulário e do consentimento, as definições éticas
e a guarda de dados, a rastreabilidade do APK e da coleta, os comentários e o
cruzamento dos iniciantes; depois, os ensaios, as medições, as capturas e as
confirmações editoriais/institucionais. A escolha do título e a folha de aprovação
também dependem do autor e do orientador. A proposta futura com iniciantes não
foi convertida em coleta necessária à conclusão do objetivo exploratório atual.
