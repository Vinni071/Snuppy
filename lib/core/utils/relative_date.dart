/// Formats [date] relative to [now] in Portuguese, e.g. "Há 5 min".
String formatRelativeDate(DateTime date, {DateTime? now}) {
  final difference = (now ?? DateTime.now()).difference(date);
  if (difference.inMinutes < 1) return 'Agora';
  if (difference.inHours < 1) return 'Há ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'Há ${difference.inHours} h';
  if (difference.inDays == 1) return 'Ontem';
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}
