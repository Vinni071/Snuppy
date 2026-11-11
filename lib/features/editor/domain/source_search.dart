/// Case-insensitive count of literal [query] occurrences in [source].
///
/// The query is matched as plain text, never as a regular expression.
int countOccurrences(String source, String query) {
  final needle = query.trim();
  if (needle.isEmpty) return 0;
  return RegExp(RegExp.escape(needle), caseSensitive: false)
      .allMatches(source)
      .length;
}
