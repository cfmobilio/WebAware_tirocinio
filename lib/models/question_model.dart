class Question {
  final String testo;
  final List<String> opzioni;
  final int rispostaCorretta;

  Question({
    required this.testo,
    required this.opzioni,
    required this.rispostaCorretta,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      testo: map['testo'] ?? '',
      opzioni: List<String>.from(map['opzioni'] ?? []),
      rispostaCorretta: map['rispostaCorretta'] ?? 0,
    );
  }
}
