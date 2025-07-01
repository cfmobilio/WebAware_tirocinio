class Simulazione {
  final String id;
  final String titolo;
  final String descrizione;
  final List<String> scelta;
  final int rispostaCorretta;
  final String feedbackPositivo;
  final String feedbackNegativo;

  Simulazione({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.scelta,
    required this.rispostaCorretta,
    required this.feedbackPositivo,
    required this.feedbackNegativo,
  });

  factory Simulazione.fromMap(String id, Map<String, dynamic> map) {
    return Simulazione(
      id: id,
      titolo: map['titolo'] ?? '',
      descrizione: map['descrizione'] ?? '',
      scelta: List<String>.from(map['scelta'] ?? []),
      rispostaCorretta: map['rispostaCorretta'] ?? 0,
      feedbackPositivo: map['feedbackPositivo'] ?? '',
      feedbackNegativo: map['feedbackNegativo'] ?? '',
    );
  }
}