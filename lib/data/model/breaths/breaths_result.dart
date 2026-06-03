class BreathsResult {
  final String partId;
  final String? nextId;
  final Duration target;
  final Duration actual;
  final Duration diff;

  final double avgAmplitude;
  final double peakAmplitude;
  final double stability;

  final int score;

  BreathsResult({
    required this.partId,
    this.nextId,
    required this.target,
    required this.actual,
    required this.diff,
    required this.avgAmplitude,
    required this.peakAmplitude,
    required this.stability,
    required this.score,
  });

  double get completionRate {
    if (target.inMilliseconds == 0) return 0;
    return (actual.inMilliseconds / target.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  bool get isPerfect => diff.inMilliseconds < 50;
  bool get isGood => diff.inMilliseconds < 120;
}