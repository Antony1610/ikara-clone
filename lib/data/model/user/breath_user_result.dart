class BreathUserResult {
  final String? indexId;
  final int id;
  final int score;
  BreathUserResult({this.indexId, required this.id, required this.score});

  factory BreathUserResult.fromJson(Map<String, dynamic> json, String indexId) {
    return BreathUserResult(indexId: indexId, id: json['id'], score: json ['score'] ?? 0);
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'score' : score
  };
}