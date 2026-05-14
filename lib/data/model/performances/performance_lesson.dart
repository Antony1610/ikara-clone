class PerformanceLesson {
  final String id;
  final String karaokeLink;
  final String lyricsLink;
  final String midiLink;
  final String singerName;
  final String songTitle;
  final String teachSingInstruct;
  final String teachSingLink;
  final String teachSingTitle;
  final String thumbnailLink;

  PerformanceLesson({
    required this.id,
    required this.karaokeLink,
    required this.lyricsLink,
    required this.midiLink,
    required this.singerName,
    required this.songTitle,
    required this.teachSingInstruct,
    required this.teachSingLink,
    required this.teachSingTitle,
    required this.thumbnailLink,
  });

  factory PerformanceLesson.fromJson(Map<String, dynamic> json, String id) {
    return PerformanceLesson(
      id: id,
      karaokeLink: json['karaokeLink'] ?? '',
      lyricsLink: json['lyricsLink'] ?? '',
      midiLink: json['midiLink'] ?? '',
      singerName: json['singerName'] ?? '',
      songTitle: json['songTitle'] ?? '',
      teachSingInstruct: json['teachSingInstruct'] ?? '',
      teachSingLink: json['teachSingLink'] ?? '',
      teachSingTitle: json['teachSingTitle'] ?? '',
      thumbnailLink: json['thumbnailLink'] ?? '',
    );
  }
}
