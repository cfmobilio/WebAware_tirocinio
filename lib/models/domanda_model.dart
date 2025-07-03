class Domanda {
  final String testo;
  final List<String> opzioni;
  final int rispostaCorretta;

  Domanda({required this.testo, required this.opzioni, required this.rispostaCorretta});

  factory Domanda.fromFirestore(Map<String, dynamic> data) {
    return Domanda(
      testo: data['testo'] ?? '',
      opzioni: List<String>.from(data['opzioni'] ?? []),
      rispostaCorretta: data['rispostaCorretta'] ?? 0,
    );
  }
}
