# Revisão do TCC Luminthor — Fase 2

Data: 15/11/2026. Escopo: questão do idioma, itens C1–C6 do roteiro. A revisão
documental desta fase está encerrada, com a decisão sobre os rótulos registrada
como pendência do autor. A Fase 3 aguarda novo “continue”.

## 1. Arquivos completos e diff

- [Arquivo principal completo](../../TCC_Teorico/Projeto_LaTeX_TCC/trabalho.tex).
- [Bibliografia completa](../../TCC_Teorico/Projeto_LaTeX_TCC/referencias.bib).
- [Manuais completos, com alteração no Apêndice A](../../TCC_Teorico/Projeto_LaTeX_TCC/apendices/manuais.tex).
- [Pacote completo dos fontes desta fase](../../output/tcc/Luminthor_Revisao_Fase_2_Fontes.zip).
- [Diff unificado por arquivo, relativo à entrega da Fase 1](revisao-fase-2.patch).
- [PDF compilado](../../output/pdf/Luminthor_Revisao_Fase_2.pdf).
- [Registro de validação](../../output/tcc/Luminthor_Revisao_Fase_2_Validacao.json).

O ZIP preserva a estrutura de diretórios do projeto e inclui os três arquivos
alterados, o pacote institucional, as sete figuras vetoriais e este relatório com
o diff e a validação. Os fontes são completos. A versão correspondente também foi
salva em `TCC_Teorico/Projeto_LaTeX_TCC/trabalho.pdf`.

Após extrair o ZIP, a compilação pode ser feita na pasta
`TCC_Teorico/Projeto_LaTeX_TCC`:

```bash
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error -file-line-error trabalho.tex
```

## 2. Registro de mudanças

As seções ainda usam a estrutura atual de seis capítulos. A nova subseção 2.4.3
desloca a discussão do padrão Visitante para 2.4.4, sem alterar seu conteúdo.

| ID | Arquivo/local | O que mudou | Situação |
| --- | --- | --- | --- |
| C1 | `trabalho.tex`, introdução e 2.1.1 | Delimitada a barreira tratada às mensagens e explicações em inglês. Apresentada a manutenção das palavras reservadas como intenção de familiarização e futura transferência para linguagens de uso geral | Concluído; intenção distinguida de efeito demonstrado |
| C2 | `trabalho.tex`, nova 2.4.3; `referencias.bib` | Discutidos Guo (2018), Dasgupta/Hill (2017) e Hermans (2020). Separados mensagens, sintaxe e controles da interface; incluídos os três marcadores de verificação pedidos | Concluído com revisão de aplicabilidade sinalizada |
| C3 | `trabalho.tex`, princípio e de 2.4.2 | Mantida a redação “Mensagens em português”, já adotada na Fase 1, e acrescentada remissão à distinção entre os três componentes de idioma | Concluído |
| C4 | `trabalho.tex`, Quadros 1 e 2 | Substituída a coluna genérica “Português” por “Mensagens em português”; acrescentada “Palavras reservadas em português”. Luminthor: Sim para mensagens, Não para palavras reservadas | Concluído; informações não verificadas de outras ferramentas estão como “A confirmar” |
| C5 | `trabalho.tex`, 2.4.3; `apendices/manuais.tex`, abertura do Apêndice A | Inserida pendência de traduzir ou justificar quatro rótulos. Propostas: Executar, Depuração, Configurações e Modelos de código. Manual documenta os nomes atuais e explicita a atualização condicionada à decisão e à implementação | Preparado; tradução efetiva ou justificativa depende do autor |
| C6 | `trabalho.tex`, 5.3 | Declarado que o efeito das palavras reservadas em inglês sobre iniciantes e a transferência para outras linguagens não foram avaliados | Concluído |
| Coerência | `trabalho.tex`, 2.3.3, 2.6 e 4.4.1 | Retiradas as caracterizações da Lumi como linguagem em português e da interface como inteiramente traduzida; mantida a descrição de mensagens e explicações em português | Concluído |
| Apresentação | `trabalho.tex`, preâmbulo e Quadros 1 e 2 | Eliminado o redimensionamento que reduziria o texto das novas colunas. Usada fonte de 10 pontos e alinhamento à esquerda; Quadro 2 em página horizontal | Concluído e inspecionado visualmente |

### Evidências e critérios adotados

**Fontes novas.** Foram conferidos título completo, autoria, ano, veículo,
paginação e DOI nos artigos originais e nos registros Crossref:

| Referência | Conferência | Fontes |
| --- | --- | --- |
| Guo (2018) | CHI 2018, p. 1–14; DOI 10.1145/3173574.3173970. O levantamento descreve barreiras de participantes não nativos em inglês; não compara versões da Lumi | [Artigo disponibilizado pelo autor](https://pg.ucsd.edu/publications/non-native-english-speakers-learning-programming_CHI-2018.pdf), [metadados Crossref](https://api.crossref.org/works/10.1145/3173574.3173970) |
| Dasgupta e Hill (2017) | Learning @ Scale, p. 33–39; DOI 10.1145/3051457.3051464. Associação observacional no Scratch, com causalidade explicitamente limitada pelos autores | [Artigo disponibilizado pelo autor](https://mako.cc/academic/dasgupta_hill-learning_code_localization-L%40S2017.pdf), [metadados Crossref](https://api.crossref.org/works/10.1145/3051457.3051464) |
| Hermans (2020) | ICER 2020, p. 259–270; DOI 10.1145/3372782.3406262. Hedy introduz complexidade sintática gradualmente em direção ao Python; isso não demonstra vantagem de palavras reservadas em inglês | [Artigo no projeto Hedy](https://hedy.org/research/Hedy_A_Gradual_Language_for_Programming_Education_2020.pdf), [metadados Crossref](https://api.crossref.org/works/10.1145/3372782.3406262) |

Os três marcadores `\verificar` foram mantidos por exigência expressa de C2.
Referem-se à revisão da aplicação dos estudos à justificativa da Lumi; a
existência e os metadados dessas publicações foram conferidos. A familiarização
com outras linguagens é uma interpretação de projeto, sem validação empírica
específica neste trabalho.

**Comparação de idioma.** O critério de mensagens exige evidência sobre
diagnósticos de erro; conteúdo didático ou interface em português não bastam.
Por isso, as antigas respostas genéricas não foram convertidas automaticamente
em afirmações sobre os diagnósticos. Ficaram “A confirmar” g++/Clang, DIMP,
Ubi-C, Pocket Code, LogicProg e ILDE. Para C/C++, as palavras reservadas são
classificadas como não traduzidas. No Pocket Code, a coluna textual foi marcada
“Não se aplica”, distinguindo-a dos rótulos dos blocos. No LogicProg, a existência
de linguagem própria continua a confirmar. A comparação funcional ampliada e os
testes diretos permanecem previstos para a Fase 4.

**Repositório.** As palavras reservadas foram conferidas em
`rust_core/src/lexer/mod.rs`. Os quatro rótulos foram conferidos em
`lib/features/editor/presentation/widgets/editor_dock.dart` e
`lib/features/home/presentation/widgets/home_navigation.dart`. Nenhum arquivo do
aplicativo foi alterado. O comentário sobre “Trace” foi relacionado ao Quadro 10,
sem modificar os registros da avaliação nem atribuir causalidade ao rótulo.

### Validação

- Compilação isolada com LaTeX/BibTeX concluída: 85 páginas, sem erros,
  referências indefinidas, rótulos duplicados ou caixas excedendo as margens.
- Inspeção visual de 14 páginas, incluindo capa, folha de rosto, introdução,
  fundamentação, dois quadros comparativos, limitação, referências e Apêndice A.
- Comparação literal com os fontes da Fase 1: preservados integralmente os
  Quadros 6–10 e o bloco técnico das seções 4.5.1–4.5.4.
- Bibliografia: 26 entradas cadastradas e 25 utilizadas; três novas referências.
- Acrescentados um marcador `\autor` e quatro `\verificar`. Permanecem os
  marcadores da fase anterior: 14 capturas, duas outras pendências do autor e
  quatro verificações. Total atual: 17 pendências do autor e oito verificações.
- Permanecem avisos preexistentes do pacote institucional sobre versões e
  comandos obsoletos. A revisão global de normas e tipografia é a Fase 8.

## 3. Marcadores `\autor` inseridos nesta fase

1. **2.4.3, rótulos da interface:** “traduzir no aplicativo ‘Execute’, ‘Trace’,
   ‘Settings’ e ‘Templates’ ou justificar.” É necessário decidir pela tradução
   ou registrar a justificativa de manutenção. Se houver tradução, implementar
   no aplicativo, identificar a versão e atualizar as instruções do Apêndice A.
   O manual atual conserva os nomes verificáveis no código.

## 4. Marcadores `\verificar` inseridos nesta fase

1. **Guo (2018), 2.4.3:** “revisar a aplicação dos resultados ao contexto de
   iniciantes brasileiros; o estudo não avalia a Lumi.” Conferir a pertinência
   da interpretação, sem tratar o estudo como avaliação da decisão da Lumi.
2. **Dasgupta e Hill (2017), 2.4.3:** “revisar a aplicabilidade de resultados de
   programação por blocos à linguagem textual Lumi.” Manter a distinção entre
   associação e causalidade e entre tradução de interface e de linguagem.
3. **Hermans (2020), 2.4.3:** “revisar a relação entre a progressão sintática da
   Hedy e a justificativa de transferência adotada para a Lumi.” Não usar a
   referência como prova de benefício de palavras reservadas em inglês.
4. **Quadros 1 e 2, 2.6:** “confirmar o idioma dos diagnósticos nas configurações
   de g++/Clang e nas versões de DIMP, Ubi-C, Pocket Code, LogicProg e ILDE
   consideradas; confirmar se LogicProg possui linguagem própria com palavras
   reservadas.” A resposta depende de fonte explícita ou teste da versão
   documentada; ausência de informação não equivale a ausência do recurso.

## 5. Perguntas que impedem a próxima fase

Nenhuma pendência impede iniciar a Fase 3 com “continue”. A decisão sobre os
rótulos continua necessária para encerrar C5 no aplicativo e na versão
definitiva do manual. As verificações comparativas serão retomadas na Fase 4;
as demais pendências da Fase 1 continuam válidas.
