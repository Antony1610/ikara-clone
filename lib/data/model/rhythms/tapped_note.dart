import 'note.dart';

class TappedNote {
  final int timeMs;
  final HitStatus status;

  const TappedNote({
    required this.timeMs,
    required this.status,
  });

  String get feedbackText {
    switch (status) {
      case HitStatus.perfect:
        return "Đúng nhịp";
      case HitStatus.early:
        return "Sớm nhịp";
      case HitStatus.late:
        return "Muộn nhịp";
      case HitStatus.miss:
        return "Lỡ nhịp";
      case HitStatus.rest:
        return "Nghỉ ngơi";
      default:
        return "";
    }
  }
}