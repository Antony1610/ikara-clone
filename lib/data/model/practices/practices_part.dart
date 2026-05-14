class PracticesPart {
  final String id;
  final String description;
  final String image;
  final String midiUrl;
  final String mp3Url;
  final String name;
  PracticesPart({
    required this.id,
    required this.description,
    required this.image,
    required this.midiUrl,
    required this.mp3Url,
    required this.name,
  });
  factory PracticesPart.fromJson(Map<String, dynamic> json, String id) {
    return PracticesPart(
      id: id,
      description: json['description'],
      image: json['image'],
      midiUrl: json['midiUrl'],
      mp3Url: json['mp3Url'],
      name: json['name'],
    );
  }
}
