class BreathsPart {
  final String partId;
  final int id;
  final Duration duration;
  final String title;
  final String type;

  BreathsPart({
    required this.partId,
    required this.id,
    required this.duration,
    required this.title,
    required this.type,
  });

  factory BreathsPart.fromJson(Map<String, dynamic> json, String id) {
    return BreathsPart(
      partId: id,
      id: json['id'],
      duration: Duration(seconds: (json['duration'] as int? ?? 0)),
      title: json['title'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
