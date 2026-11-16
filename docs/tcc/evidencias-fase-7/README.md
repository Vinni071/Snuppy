# Reprodução técnica de T3 — 15/11/2026

Foram executados cinco cenários em cada revisão do motor:
`47ea64a38162d7b3ff3c22197841d21ae5c30af3` e
`2e33f7ed800636fa0068b663e15789a693d9af1b`. As chamadas de cada conjunto ocorrem
sequencialmente no mesmo processo. Os programas mínimos foram construídos a partir
das referências metodológicas, sem recuperar a edição do participante.

- T2 sem correção: erro sintático de fechamento de parêntese, sem rastro.
- T3 substitui T2: divisão por zero em execução, com dois eventos anteriores.
- T3 é acrescentada sem remover T2: permanece o erro sintático, sem interpretação.
- T2 corrigida: saída 15, como controle.
- T3 substitui T2 corrigida: divisão por zero, com dois eventos.

Os retornos completos estão em `t3-atual.json` e `t3-historico.json`; as
compilações estão nos arquivos correspondentes. `t3-probe.rs` contém o programa
auxiliar usado. Não houve alteração de fonte do aplicativo, instalação em telefone
ou ensaio da interação no APK. O resultado torna plausível a hipótese de texto
remanescente, sem confirmar a causa do relato de novembro.

Na raiz, com Python 3.12+, Git, Cargo e dependências em cache:

```sh
python3 docs/tcc/evidencias-fase-7/reproduzir-t3.py --output /tmp/tcc-t3
```

O script cria projetos e builds temporários, extrai a revisão histórica do Git
local e grava resultados no diretório solicitado. Usa o Cargo.lock do motor e
`--offline`; não busca dependências na rede nem altera o repositório. Registra o
commit atual efetivamente utilizado e verifica os resultados relevantes.

A planilha original da coleta não está neste pacote. O cruzamento entre experiência
e notas neutras continua pendente de conferência na fonte; os comentários completos
não foram reconstruídos a partir de temas. Não houve nova coleta com participantes.
