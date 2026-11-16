# Revisão do TCC Luminthor — Fase 5

Data: 15/11/2026. Escopo: metodologia e ética, itens H1–H7. A revisão documental
da fase foi concluída; informações e documentos ausentes permanecem sinalizados
para o autor. A Fase 6 aguarda novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal completo](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Bibliografia completa](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib).
- [Novo arquivo dos apêndices C e D](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/instrumentos.tex).
- [Diff unificado em relação à Fase 4](revisao-fase-5.patch).
- [Pacote completo dos fontes](../../output/tcc/Luminthor_Revisao_Fase_5_Fontes.zip).
- [PDF compilado](../../output/pdf/Luminthor_Revisao_Fase_5.pdf).
- [Conferência de fontes e evidências](revisao-fase-5-fontes.md).
- [Registro de validação](../../output/tcc/Luminthor_Revisao_Fase_5_Validacao.json).

Foram alterados `trabalho.tex` e `referencias.bib` e acrescentado
`apendices/instrumentos.tex`. O ZIP inclui os fontes necessários à compilação,
com o pacote institucional, os manuais e as sete figuras vetoriais. O PDF
na pasta do projeto é idêntico ao PDF da entrega desta fase.

Compilar na pasta `TCC_Teorico/Projeto_LaTeX_TCC`:

```bash
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

## 2. Registro de mudanças

| ID | Arquivo/local | Mudança e alcance |
| --- | --- | --- |
| H1 | `trabalho.tex`, 4.1; `.bib` | Classificação aplicada e tecnológica, com objetivos exploratórios, abordagem quantitativa descritiva apoiada por relatos qualitativos e procedimentos bibliográfico, desenvolvimento e levantamento. Acrescentados Gil (2002) e Wazlawick (2021), com conferência integral deste último ainda pendente |
| H1 | 4.1.1; `.bib` | DSR organizada retrospectivamente com Hevner et al. (2004) e Peffers et al. (2007), relacionando atividades e evidências sem alegar adoção formal desde o início |
| H2 | 4.2.1; Quadro 2 | Dois marcos históricos, entregas, identificação dos registros e contagens de 65/58 e 65/155. Distinguido pacote com alterações locais de commit; demais ciclos e logs completos de novembro pendentes |
| H3 | 4.2.2; Quadros 3 e 4 | Sete RF e três RNF reconstruídos, com critérios verificáveis e matriz requisito × caso × evidência. Arquivos de teste identificados; inspeção do código diferenciada de execução e de evidência histórica |
| H4 | 4.3 | Origem do LUMI-AV02 e diferença entre planejamento de 13 questões e aplicação de 20. Marcadas alterações e justificativa original do instrumento próprio; explicitados itens afirmativos e ausência de validação documentada |
| H4 | 4.3 | Recrutamento e identificação/versionamento do APK sinalizados como pendências. Número de envios não foi tratado como número de convites |
| H4 | 4.3.1 | Descritas categorias humanas de tarefas e comentários e a vinculação das anotações ao hash da planilha. Autoria e protocolo completo de codificação permanecem pendentes; não se inventaram avaliadores, concordância ou saturação |
| H5 | `apendices/instrumentos.tex`; remissões na introdução e em 4.3–4.4 | Apêndices C e D criados com espaços reservados e pendências visíveis. A estrutura conhecida e as opções registradas de aceite foram diferenciadas dos textos integrais ainda ausentes |
| H6 | 4.5.1–4.5.4; 6.3 | Ameaças à validade de construção, interna, externa e de conclusão reunidas em uma seção. Discussão passou a remeter a ela; mantidas as implicações e prioridades dos resultados |
| H6 | 4.5.3 | Separadas as variáveis: cinco participantes com experiência além do nível introdutório; seis com mais de 12 meses e dois com menos de três meses. Consulta ao formulário não foi usada como indicador de dependência exclusiva de celular |
| H7 | 4.4; `.bib` | Acrescentada seção de ética e dados, com referência oficial à Resolução CNS nº 510/2016 e pendências de enquadramento, guarda e declaração de maioridade. Não foi afirmada aprovação ou dispensa |
| H, remissões e apresentação | Sumário e lista de siglas | Acrescentadas DSR/RF/RNF, retirada R&D que deixou de caracterizar o método e ampliada a caixa de números do sumário para três dígitos |

### Validação e preservação

PDF compilado com **109 páginas**, sem erros, referências indefinidas,
rótulos duplicados ou caixas excedentes (`Overfull`). Foram renderizadas e
inspecionadas 27 páginas, abrangendo a metodologia, o sumário,
a discussão, as referências e os novos apêndices. A bibliografia tem
59 entradas cadastradas e 58 utilizadas; Tims continua sem uso.

Os cinco quadros numéricos de resultados foram preservados literalmente,
incluindo fontes e notas. Os três novos quadros metodológicos alteraram somente
a numeração automática:

| Rótulo | Fase 4 | Fase 5 |
| --- | ---: | ---: |
| `quad:validacao_tecnica` | 4 | 7 |
| `quad:perfil_participantes` | 5 | 8 |
| `quad:respostas_tarefas` | 6 | 9 |
| `quad:usabilidade_participantes` | 7 | 10 |
| `quad:temas_comentarios` | 8 | 11 |

O bloco técnico 5.3.1–5.3.4, o Código 1 da gramática e os manuais foram
preservados literalmente. As 14 capturas continuam pendentes. Nenhum código do
aplicativo foi alterado. Não se reexecutaram as suítes Rust/Flutter nem se
realizaram ensaios em Android físico nesta fase; a validação executada foi a
compilação e a conferência dos artefatos documentais, da rastreabilidade e da
preservação. O diff foi conferido em aplicação simulada contra os fontes da Fase 4.

## 3. Todos os novos marcadores `\autor{}`

1. `\autor{informar os demais ciclos, com datas, entregas e evidências, e fornecer os logs completos dos testes de 11/11/2026.}`

2. `\autor{validar a lista de RF e RNF, seu escopo e os critérios de aceitação; confirmar se há requisitos originalmente definidos que não aparecem nesta reconstrução.}`

3. `\autor{explicar quando, por que e por quem o LUMI-AV02 foi alterado para o formulário de 20 questões; informar a justificativa original para utilizar instrumento próprio em lugar de uma escala validada.}`

4. `\autor{informar canal de recrutamento, número de convites, vínculo dos participantes com o autor e eventuais incentivos; os 12 envios não permitem inferir quantas pessoas foram convidadas.}`

5. `\autor{informar versão e hash SHA-256 do APK distribuído; esclarecer se houve mais de uma versão entre 9 e 13/11/2026 e, se possível, relacioná-las aos envios sem publicar identificadores pessoais.}`

6. `\autor{informar quem categorizou os comentários, como os temas foram definidos e revisados e como foi tratada a repetição de um tema nos dois campos de uma mesma pessoa; confirmar se houve mais de um avaliador. Não atribuir concordância entre avaliadores ou saturação sem registros correspondentes.}`

7. `\autor{informar o enquadramento ético definido com o orientador e o registro institucional correspondente, incluindo norma aplicável, parecer ou fundamento de eventual dispensa. Não há documento fornecido que permita afirmar aprovação ou dispensa nesta monografia.}`

8. `\autor{descrever tratamento e guarda de nomes e e-mails: local e responsável, pessoas com acesso, separação dos dados de análise, prazo de retenção e destinação; informar o procedimento de retirada de dados efetivamente comunicado e adotado.}`

9. `\autor{informar, com o orientador, como serão tratados os registros sem declaração de maioridade e documentar a decisão; se o critério de inclusão mudar, atualizar os agregados e todos os resultados correspondentes.}`

10. `\autor{fornecer o formulário efetivamente aplicado na íntegra: apresentação, instruções, 20 questões, códigos e programas das tarefas, alternativas de resposta, obrigatoriedade dos campos e regras de salto; preservar as datas e diferenças entre versões, caso tenham sido utilizadas.}`

11. `\autor{fornecer o texto de consentimento efetivamente apresentado aos participantes, incluindo informações prévias, contato, direitos, opções de aceite e recusa e suas eventuais versões e datas; reproduzir o documento sem dados pessoais dos respondentes.}`

Há **11 novos marcadores**. Somados aos anteriores, permanecem
14 capturas e 19 outras pendências do autor. A classificação da
fase como concluída refere-se ao trabalho documental possível, com essas lacunas
explicitadas; não à obtenção dos documentos e informações ausentes.

## 4. Todos os novos marcadores `\verificar{}`

1. `\verificar{H1: conferir no volume de Wazlawick (2021) os trechos utilizados para os eixos de classificação; a edição foi conferida no catálogo da editora, mas o texto integral não foi consultado nesta revisão. Gil (2002, cap. 4) foi consultado.}`

Há um marcador novo e 12 verificações pendentes no conjunto. O ponto novo
é a consulta aos trechos da terceira edição de Wazlawick, cujo catálogo foi
conferido. A quarta edição de Gil foi consultada, inclusive a classificação e o
levantamento. O alcance de cada fonte está no registro próprio desta fase.

## 5. Questões que bloqueiam a próxima fase

Nenhuma impede iniciar a Fase 6, sobre desenvolvimento, mediante novo “continue”.
Os campos de autor acima permitem prosseguir sem inventar informações de coleta
ou ética. Para finalizar a monografia, continuam necessários os textos integrais
do formulário e do consentimento, a identificação do APK, o histórico da coleta
e as decisões com o orientador sobre enquadramento, guarda e maioridade.

A ausência dessas informações não foi resolvida por suposição. Eventual mudança
no critério de inclusão deve preceder uma reanálise dos resultados; esta fase
preservou integralmente os quadros numéricos existentes.
