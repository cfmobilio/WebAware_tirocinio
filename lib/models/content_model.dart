class ContentModel {
  final String descrizione;
  final String titolo;
  final String? videoUrl;
  final int livello;

  ContentModel({
    required this.descrizione,
    required this.titolo,
    this.videoUrl,
    required this.livello,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map, int livello) {
    return ContentModel(
      descrizione: map['descrizione'] ?? '',
      titolo: map['titolo'] ?? '',
      videoUrl: map['videoUrl'],
      livello: livello,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descrizione': descrizione,
      'titolo': titolo,
      'videoUrl': videoUrl,
    };
  }
}