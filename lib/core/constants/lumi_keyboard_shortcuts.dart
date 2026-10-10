class LumiKeyboardShortcut {
  final String label;
  final String tooltip;
  final String text;
  final String suffix;

  const LumiKeyboardShortcut({
    required this.label,
    required this.tooltip,
    required this.text,
    this.suffix = '',
  });
}

const lumiKeyboardShortcuts = [
  LumiKeyboardShortcut(
    label: 'Tab',
    tooltip: 'Indentar com dois espaços',
    text: '  ',
  ),
  LumiKeyboardShortcut(label: ';', tooltip: 'Ponto e vírgula', text: ';'),
  LumiKeyboardShortcut(
    label: '()',
    tooltip: 'Inserir parênteses ou envolver a seleção',
    text: '(',
    suffix: ')',
  ),
  LumiKeyboardShortcut(
    label: '{}',
    tooltip: 'Inserir chaves ou envolver a seleção',
    text: '{',
    suffix: '}',
  ),
  LumiKeyboardShortcut(
    label: '""',
    tooltip: 'Inserir aspas ou envolver a seleção',
    text: '"',
    suffix: '"',
  ),
  LumiKeyboardShortcut(label: '=', tooltip: 'Atribuição', text: '='),
  LumiKeyboardShortcut(label: ',', tooltip: 'Vírgula', text: ','),
  LumiKeyboardShortcut(
      label: '//', tooltip: 'Comentário de linha', text: '// '),
  LumiKeyboardShortcut(
      label: 'var', tooltip: 'Declarar variável', text: 'var '),
  LumiKeyboardShortcut(
    label: 'const',
    tooltip: 'Declarar constante',
    text: 'const ',
  ),
  LumiKeyboardShortcut(
    label: 'print',
    tooltip: 'Imprimir um valor',
    text: 'print(',
    suffix: ');',
  ),
  LumiKeyboardShortcut(label: 'if', tooltip: 'Condição', text: 'if '),
  LumiKeyboardShortcut(label: 'else', tooltip: 'Alternativa', text: 'else '),
  LumiKeyboardShortcut(
      label: 'while', tooltip: 'Repetição while', text: 'while '),
  LumiKeyboardShortcut(label: 'for', tooltip: 'Repetição for', text: 'for '),
  LumiKeyboardShortcut(label: 'fn', tooltip: 'Declarar função', text: 'fn '),
  LumiKeyboardShortcut(
      label: 'return', tooltip: 'Retornar valor', text: 'return '),
  LumiKeyboardShortcut(label: 'true', tooltip: 'Verdadeiro', text: 'true'),
  LumiKeyboardShortcut(label: 'false', tooltip: 'Falso', text: 'false'),
  LumiKeyboardShortcut(label: 'and', tooltip: 'E lógico', text: ' and '),
  LumiKeyboardShortcut(label: 'or', tooltip: 'Ou lógico', text: ' or '),
  LumiKeyboardShortcut(label: 'not', tooltip: 'Negação lógica', text: 'not '),
  LumiKeyboardShortcut(label: '+', tooltip: 'Adição', text: '+'),
  LumiKeyboardShortcut(label: '-', tooltip: 'Subtração', text: '-'),
  LumiKeyboardShortcut(label: '*', tooltip: 'Multiplicação', text: '*'),
  LumiKeyboardShortcut(label: '/', tooltip: 'Divisão', text: '/'),
  LumiKeyboardShortcut(label: '%', tooltip: 'Resto da divisão', text: '%'),
  LumiKeyboardShortcut(label: '==', tooltip: 'Igualdade', text: '=='),
  LumiKeyboardShortcut(label: '!=', tooltip: 'Diferença', text: '!='),
  LumiKeyboardShortcut(label: '<', tooltip: 'Menor que', text: '<'),
  LumiKeyboardShortcut(label: '>', tooltip: 'Maior que', text: '>'),
  LumiKeyboardShortcut(label: '<=', tooltip: 'Menor ou igual', text: '<='),
  LumiKeyboardShortcut(label: '>=', tooltip: 'Maior ou igual', text: '>='),
];
