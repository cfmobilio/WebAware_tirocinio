// domanda.dart
class Domanda {
  final String testo;
  final List<String> opzioni;
  final int rispostaCorretta;

  Domanda({
    required this.testo,
    required this.opzioni,
    required this.rispostaCorretta,
  });

  factory Domanda.fromMap(Map<String, dynamic> map) {
    return Domanda(
      testo: map['testo'],
      opzioni: List<String>.from(map['opzioni']),
      rispostaCorretta: map['rispostaCorretta'],
    );
  }
}
