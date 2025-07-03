class Insight {
  final String titolo;
  final String descrizione;

  Insight({required this.titolo, required this.descrizione});

  factory Insight.fromFirestore(Map<String, dynamic> data) {
    return Insight(
      titolo: data['titolo'] ?? '',
      descrizione: data['descrizione'] ?? '',
    );
  }
}
