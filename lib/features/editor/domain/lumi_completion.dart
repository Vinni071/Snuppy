/// A suggestion for the word being typed in the editor.
class LumiCompletion {
  final String label;
  final String detail;

  /// Inserted before the cursor, replacing the typed prefix.
  final String text;

  /// Inserted after the cursor.
  final String suffix;

  const LumiCompletion({
    required this.label,
    required this.detail,
    required this.text,
    this.suffix = '',
  });
}

class LumiCompletionResult {
  /// Where the typed prefix begins. The prefix ends at the cursor.
  final int start;
  final List<LumiCompletion> items;

  const LumiCompletionResult({required this.start, required this.items});

  static const none = LumiCompletionResult(start: 0, items: []);

  bool get isEmpty => items.isEmpty;
}

const _keywords = [
  LumiCompletion(label: 'var', detail: 'Declarar variável', text: 'var '),
  LumiCompletion(label: 'const', detail: 'Declarar constante', text: 'const '),
  LumiCompletion(
      label: 'print',
      detail: 'Imprimir um valor',
      text: 'print(',
      suffix: ');'),
  LumiCompletion(label: 'if', detail: 'Condição', text: 'if '),
  LumiCompletion(label: 'else', detail: 'Alternativa', text: 'else '),
  LumiCompletion(label: 'while', detail: 'Repetição while', text: 'while '),
  LumiCompletion(label: 'for', detail: 'Repetição for', text: 'for '),
  LumiCompletion(label: 'in', detail: 'Iterável do for', text: 'in '),
  LumiCompletion(label: 'fn', detail: 'Declarar função', text: 'fn '),
  LumiCompletion(label: 'return', detail: 'Retornar valor', text: 'return '),
  LumiCompletion(label: 'break', detail: 'Sair do laço', text: 'break;'),
  LumiCompletion(label: 'continue', detail: 'Próxima volta', text: 'continue;'),
  LumiCompletion(label: 'true', detail: 'Verdadeiro', text: 'true'),
  LumiCompletion(label: 'false', detail: 'Falso', text: 'false'),
  LumiCompletion(label: 'null', detail: 'Valor nulo', text: 'null'),
  LumiCompletion(label: 'and', detail: 'E lógico', text: 'and '),
  LumiCompletion(label: 'or', detail: 'Ou lógico', text: 'or '),
  LumiCompletion(label: 'not', detail: 'Negação lógica', text: 'not '),
];

/// Keywords followed by a name the user is inventing, not recalling.
const _declaringKeywords = {'var', 'const', 'fn', 'for'};

// Mirrors the comment, string and identifier rules in rust_core/src/lexer.
// Unterminated comments and strings run to the end of the source.
final _tokenPattern = RegExp(
  r'//[^\n]*'
  r'|/\*[\s\S]*?(?:\*/|$)'
  r'|"(?:[^"\\]|\\[\s\S]?)*(?:"|$)'
  r'|[A-Za-z_][A-Za-z0-9_]*'
  r'|[0-9]+(?:\.[0-9]+)?'
  r'|[{}()]',
);
final _identifierStart = RegExp(r'^[A-Za-z_]');

bool _isIdentifier(String token) => _identifierStart.hasMatch(token);

/// Suggests how to finish the identifier that ends at [cursor], offering only
/// names the semantic analyzer would accept at that position.
LumiCompletionResult lumiCompletionsAt(String source, int cursor) {
  if (cursor <= 0 || cursor > source.length) return LumiCompletionResult.none;

  final matches = _tokenPattern.allMatches(source).toList();
  final index = matches.indexWhere((m) => m.start < cursor && cursor <= m.end);
  if (index < 0) return LumiCompletionResult.none;
  final current = matches[index];
  // Comments, strings and numbers don't complete; neither does a word whose
  // remainder sits after the cursor.
  if (!_isIdentifier(current[0]!) || cursor != current.end) {
    return LumiCompletionResult.none;
  }

  List<String> code(Iterable<Match> tokens) => [
        for (final token in tokens)
          if (!token[0]!.startsWith('/')) token[0]!,
      ];
  final before = code(matches.take(index));
  final after = code(matches.skip(index + 1));

  if (before.isNotEmpty && _declaringKeywords.contains(before.last)) {
    return LumiCompletionResult.none;
  }
  final scoped = _visibleSymbols(before);
  if (scoped == null) return LumiCompletionResult.none;

  final callHasParens = source.startsWith('(', cursor);
  final functions = [
    for (final name in _topLevelFunctions([...before, ...after]))
      LumiCompletion(
        label: name,
        detail: 'Função',
        text: callHasParens ? name : '$name(',
        suffix: callHasParens ? '' : ')',
      ),
  ];

  final prefix = current[0]!;
  final lowerPrefix = prefix.toLowerCase();
  final seen = <String>{};
  final items = [
    for (final item in [...scoped, ...functions, ..._keywords])
      if (item.label != prefix &&
          item.label.toLowerCase().startsWith(lowerPrefix) &&
          seen.add(item.label))
        item,
  ];
  return LumiCompletionResult(start: current.start, items: items);
}

/// Only top-level functions are registered ahead of use by the semantic
/// analyzer, which makes them callable from anywhere in the file.
List<String> _topLevelFunctions(List<String> tokens) {
  final names = <String>[];
  var depth = 0;
  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (token == '{') depth++;
    if (token == '}') depth--;
    if (token == 'fn' &&
        depth == 0 &&
        i + 1 < tokens.length &&
        _isIdentifier(tokens[i + 1])) {
      names.add(tokens[i + 1]);
    }
  }
  return names;
}

/// Variables and parameters in scope after [tokens], innermost and most recent
/// first. Returns null if the tokens end inside a parameter list.
List<LumiCompletion>? _visibleSymbols(List<String> tokens) {
  final scopes = <List<LumiCompletion>>[[]];
  // Parameters and `for` variables belong to the block that follows them.
  var pending = <LumiCompletion>[];

  LumiCompletion symbol(String name, String detail) =>
      LumiCompletion(label: name, detail: detail, text: name);
  bool hasName(int i) => i < tokens.length && _isIdentifier(tokens[i]);

  for (var i = 0; i < tokens.length; i++) {
    switch (tokens[i]) {
      case '{':
        scopes.add(pending);
        pending = [];
      case '}':
        if (scopes.length > 1) scopes.removeLast();
      case 'var':
        if (hasName(i + 1)) scopes.last.add(symbol(tokens[++i], 'Variável'));
      case 'const':
        if (hasName(i + 1)) scopes.last.add(symbol(tokens[++i], 'Constante'));
      case 'for':
        if (hasName(i + 1)) {
          pending.add(symbol(tokens[++i], 'Variável do for'));
        }
      case 'fn':
        if (i + 2 < tokens.length && tokens[i + 2] == '(') {
          i += 3;
          while (i < tokens.length && tokens[i] != ')') {
            if (_isIdentifier(tokens[i])) {
              pending.add(symbol(tokens[i], 'Parâmetro'));
            }
            i++;
          }
          if (i == tokens.length) return null;
        }
    }
  }
  return [
    for (final scope in scopes.reversed) ...scope.reversed,
  ];
}
