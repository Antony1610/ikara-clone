class Question {
  final String indexId;
  final String id;
  final String correctAnswer;
  final List<String> options;
  final String question;

  Question({
    required this.indexId,
    required this.id,
    required this.correctAnswer,
    required this.options,
    required this.question,
  });

  factory Question.fromJson(Map<String, dynamic> json, String indexId) {
    return Question(
      indexId: indexId,
      id: json['id'],
      correctAnswer: json['correctAnswer'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      question: json['question'] ?? '',
    );
  }
}
