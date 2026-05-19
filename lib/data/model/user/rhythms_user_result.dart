class RhythmsUserResult {
  final String? indexId;
  final int id;
  final String pattern;
  final int score;
  final String status;
  final String title;
  RhythmsUserResult({
    this.indexId,
    required this.id,
    required this.pattern,
    required this.score,
    required this.status,
    required this.title,
  });
  factory RhythmsUserResult.fromJson(
    Map<String, dynamic> json,
    String indexId,
  ) {
    return RhythmsUserResult(
      indexId: indexId,
      id: json['id'],
      pattern: json['pattern'] ?? '',
      score: json['score'] ?? 0,
      status: json['status'] ?? 'READY',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'pattern' : pattern,
    'score' : score,
    'status' : status,
    'title' : title
  };
}
