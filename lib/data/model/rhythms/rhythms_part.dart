enum BeatType { beat, rest }

class RhythmsPart {
  final String indexId;
  final int id;
  final String pattern;
  final String title;

  RhythmsPart({required this.indexId,required this.id, required this.pattern, required this.title});

  factory RhythmsPart.fromJson(Map<String, dynamic> json, String indexId) {
    return RhythmsPart(
      indexId: indexId,
      id: json['id'],
      pattern: json['pattern'] ?? '',
      title: json['title'] ?? '',
    );
  }

  List<List<BeatType>> get measures {
    return pattern
        .split(';')
        .where((s) => s.isNotEmpty)
        .map(
          (measure) => measure
              .split(',')
              .map((b) => b.trim() == 'beat' ? BeatType.beat : BeatType.rest)
              .toList(),
        )
        .toList();
  }

  int get measureCount => measures.length;

  int get beatsPerMeasure => measures.isNotEmpty ? measures.first.length : 0;
}
