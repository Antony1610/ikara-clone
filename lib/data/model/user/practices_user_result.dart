class PracticesUserResult {
  final String? indexId;
  final int id;
  final String name;
  final String description;
  final int score;
  final String image;
  final String midiUrl;
  final String mp3Url;
  final String status;

  PracticesUserResult({
    this.indexId,
    required this.id,
    required this.name,
    required this.description,
    required this.score,
    required this.image,
    required this.midiUrl,
    required this.mp3Url,
    required this.status,
  });

  factory PracticesUserResult.fromJson(
    Map<String, dynamic> json,
    String indexId,
  ) {
    return PracticesUserResult(
      indexId: indexId,
      id: json['id'],
      name: json['name'],
      description: json['description'],
      score: json['score'],
      image: json['image'],
      midiUrl: json['midiUrl'],
      mp3Url: json['mp3Url'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'description' : description,
    'score' : score,
    'image' : image,
    'midiUrl' : midiUrl,
    'mp3Url' : mp3Url,
    'status' : status
  };
}
