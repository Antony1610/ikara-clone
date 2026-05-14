class LyricsToken {
  final String text;
  final int startMs;
  final bool isNewLine;
  final bool isNewVerse;
  LyricsToken({
    required this.text,
    required this.startMs,
    required this.isNewLine,
    required this.isNewVerse,
  });
}
