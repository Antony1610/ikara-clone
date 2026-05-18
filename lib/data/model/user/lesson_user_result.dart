class LessonUserResult {
  final String? partIndex;
  final String id;
  final int process;
  final String status;

  LessonUserResult({
    this.partIndex,
    required this.id,
    required this.process,
    required this.status,
  });

  factory LessonUserResult.fromJson(Map<String, dynamic> json, String partIndex) =>
      LessonUserResult(
        partIndex: partIndex,
        id: json['id'],
        process: json['process'] ?? 0,
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'process': process,
    'status': status,
  };
}