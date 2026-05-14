enum NoteType { beat, rest }

enum HitStatus { none, perfect, early, late, miss, wrong , rest}

class Note {
  final int id;
  final NoteType type;
  final int timeMs;
  final int measure;
  HitStatus status;
  final bool isHighlighted;
  Note({
    required this.id,
    required this.type,
    required this.timeMs,
    required this.measure,
    this.status = HitStatus.none,
    this.isHighlighted = false
  });
  Note copyWith({
    int? id,
    NoteType? type,
    int? timeMs,
    int? measure,
    HitStatus? status,
    bool? isHighlighted
  }) {
    return Note(
      id: id ?? this.id,
      type: type ?? this.type,
      timeMs: timeMs ?? this.timeMs,
      measure: measure ?? this.measure,
      status: status ?? this.status,
      isHighlighted: isHighlighted ?? this.isHighlighted
    );
  }
}
