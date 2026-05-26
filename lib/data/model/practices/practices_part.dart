class PracticesPart {
  final String indexId;
  final int id;
  final String description;
  final String image;
  final String midiUrl;
  final String mp3Url;
  final String name;
  PracticesPart({
    required this.indexId,
    required this.id,
    required this.description,
    required this.image,
    required this.midiUrl,
    required this.mp3Url,
    required this.name,
  });
  factory PracticesPart.fromJson(Map<String, dynamic> json, String indexId) {
    return PracticesPart(
      indexId: indexId,
      id: json['id'],
      description: json['description'],
      image: json['image'],
      midiUrl: json['midiUrl'],
      mp3Url: json['mp3Url'],
      name: json['name'],
    );
  }
}
