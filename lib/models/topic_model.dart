class Topic {
  final String titolo;
  final String descrizione;
  final String videoUrl;

  Topic({
    required this.titolo,
    required this.descrizione,
    required this.videoUrl,
  });

  factory Topic.fromMap(Map<String, dynamic> data) {
    return Topic(
      titolo: data['titolo'] ?? '',
      descrizione: data['descrizione'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}
