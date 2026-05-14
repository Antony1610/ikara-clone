class RhythmsResult {
  final String rhythmId;
  final int score;
  final int perfect;
  final int late;
  final int early;
  final int miss;
  RhythmsResult({
    required this.rhythmId,
    required this.score,
    required this.perfect,
    required this.late,
    required this.early,
    required this.miss,
  });
}
