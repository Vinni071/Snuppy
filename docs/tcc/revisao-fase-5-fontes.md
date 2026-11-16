# Conferência de fontes — Fase 5

Consulta em 15/11/2026. Este registro distingue texto consultado, metadados,
inspeção do código e registros históricos. Os textos integrais de terceiros não
integram o pacote de fontes.

## Bibliografia acrescentada

| Chave | Conferência e alcance | Fonte primária |
| --- | --- | --- |
| `gil2002` | Quarta edição, Atlas, São Paulo, 2002; folha de rosto e ficha catalográfica conferidas. Capítulo 4, especialmente p. 41–44 e a seção de levantamento, fundamenta a distinção entre objetivos e procedimentos. A classificação do próprio TCC é uma análise de seus procedimentos | [Livro disponibilizado pela UECE](https://uece.br/nucleodelinguasitaperi/wp-content/uploads/sites/91/2021/09/gil_como_elaborar_projeto_de_pesquisa-1.pdf) |
| `wazlawick2021` | Terceira edição, ISBN 9788595151093. O catálogo informa edição 3/2021 e data comercial de publicação 03/11/2020; adotou-se o ano da edição, 2021. O volume integral não foi consultado; conferir os trechos utilizados antes de fechar a referência | [Catálogo da editora](https://www.grupogen.com.br/metodologia-de-pesquisa-para-ciencia-da-computacao) |
| `hevner2004` | Autoria, MIS Quarterly 28(1), p. 75–105 e DOI 10.2307/25148625 conferidos. Diretrizes de artefato, relevância e avaliação consultadas, em especial quadro da p. 83 | [Registro do periódico](https://aisel.aisnet.org/misq/vol28/iss1/6/), [artigo consultado](https://damien.house/sites/default/files/Hevner-et-al-MISQ-2004.pdf) |
| `peffers2007` | Quatro autores; JMIS 24(3), p. 45–77, DOI 10.2753/MIS0742-1222240302. Seis atividades conferidas no manuscrito. A paginação do manuscrito diverge do registro editorial; a bibliografia segue o artigo publicado, 45–77 | [Registro editorial](https://doi.org/10.2753/MIS0742-1222240302), [manuscrito consultado](https://wise.vub.ac.be/sites/default/files/thesis_info/Design_Science_Research_Methodology_2008.pdf), [cópia do artigo publicado](https://indico.cern.ch/event/1542774/contributions/6494311/attachments/3080345/5465431/Peffers_2007_A%20Design%20Science%20Research%20Methodology%20for%20Information%20Systems%20Research.pdf) |
| `cns5102016` | Resolução CNS nº 510, de 7/4/2016, consultada em fonte oficial, arts. 1º, 3º e 4º. Utilizada para contextualizar a decisão ética ainda pendente; não se concluiu aprovação, dispensa ou enquadramento automático do estudo | [CNS, documento oficial](https://www.gov.br/conselho-nacional-de-saude/pt-br/acesso-a-informacao/atos-normativos/resolucoes/2016/resolucao-no-510.pdf), [texto do Ministério da Saúde](https://bvsms.saude.gov.br/bvs/saudelegis/cns/2016/res0510_07_04_2016.html) |

A DSR foi utilizada como organização retrospectiva da documentação. A correspondência
entre atividades e capítulos não demonstra que o método tenha orientado historicamente
todos os ciclos. A avaliação do artefato foi expressamente delimitada.

## Evidências locais

| Registro | Uso e limite |
| --- | --- |
| `docs/checkpoint/checkpoint-2026-10-10.md` e `docs/checkpoint/validacao/` | Entregas e contagens históricas de outubro: 65 Rust e 58 Flutter. O pacote inclui mudanças além do commit de base; não foi reduzido à identidade desse commit |
| Registro de 11/11 no capítulo de resultados e revisão `47ea64a` | Contagens históricas de 65 Rust e 155 Flutter e estado do desenvolvimento. Os logs completos de novembro não foram encontrados nos documentos locais; ficou pendência explícita |
| `test/engine_test.dart`, `test/editor_debugger_test.dart`, `test/editor_theme_test.dart` | Casos FFI, Unicode, rastro, escopos, saída e temas inspecionados; não reexecutados nesta fase |
| `test/unit/workspace_test.dart`, `test/workspace_test.dart`, `test/widget_test.dart` | Persistência, recuperação, criação, edição, importação/exportação por serviço simulado e widgets. A matriz aponta os três arquivos |
| `test/learning_test.dart`, `test/unit/learning_progress_test.dart`, `test/lumi_completion_test.dart` | Casos de progressão, interface e sugestões, incluindo condições negativas. Não são evidência de aprendizagem |
| `rust_core/src/api.rs`, `rust_core/src/interpreter/mod.rs` | Pipeline e interrupção de laço. O teste de proteção usa 100 passos; o padrão de 10.000 foi conferido no código, sem atribuir ao teste uma verificação desse valor |
| `docs/avaliacao-luminthor/README.md` e `formulario-participante.md` | LUMI-AV02 é planejamento de 13 questões, distinto do instrumento de 20 questões aplicado. Seu consentimento não foi apresentado como redação comprovadamente enviada |
| `docs/avaliacao-luminthor/resultados/README.md`, `resumo-2026-11-14.json` e `analisar_respostas.py` | Datas, critérios, categorias e agregados. Categorias humanas são vinculadas ao hash da exportação; o script não classifica automaticamente comentários. A planilha original permanece fora do repositório |

A fonte de dados do resumo é identificada por SHA-256
`a445e1595e352b67a2240a0ae5715ec7cbc77fa68ad37188311f16c7ad396917`.
O hash identifica a planilha, **não o APK**. A revisão de código inspecionada é
`2e33f7ed800636fa0068b663e15789a693d9af1b`; ela tampouco identifica o instalador recebido.

## Limites documentais mantidos

- Recrutamento, justificativa original do instrumento, alterações entre versões,
  identificação do APK e protocolo completo de categorização dependem do autor.
- O perfil de cinco usuários além do nível introdutório é distinto do tempo de
  experiência: seis têm mais de 12 meses e dois menos de três meses.
- O resumo não contém enunciados completos de todas as questões nem todo o
  consentimento. Os apêndices C e D têm pendências visíveis, sem reconstrução literal.
- O limite de idade não foi inferido a partir do aceite sem declaração de maioridade.
  Qualquer mudança de inclusão exige reanálise; os quadros de resultados foram preservados.
- O atendimento sem rede em Android e a compatibilidade física não foram declarados
  comprovados por mera existência da FFI ou de testes de widgets.
