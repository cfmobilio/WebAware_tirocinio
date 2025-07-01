import '../../../models/emergency_model.dart';

class EmergencyViewModel {
  final List<Emergency> emergenze = [
    Emergency(
      titolo: "Polizia Postale e delle Comunicazioni",
      icona: "assets/police.png",
      sito: "https://www.commissariatodips.it",
      contatto: "+39 06 4620 2222",
    ),
    Emergency(
      titolo: "Sicurezza Informatica e Attacchi Hacker",
      icona: "assets/shield.png",
      sito: "https://www.cert-agid.gov.it",
      contatto: "cert@cert-agid.gov.it",
    ),
    Emergency(
      titolo: "Cyberbullismo e Minori Online",
      icona: "assets/theatre.png",
      sito: "https://www.azzurro.it",
      contatto: "1.96.96",
    ),
    Emergency(
      titolo: "Truffe Online e Carte di Credito",
      icona: "assets/credit-card.png",
      sito: "https://www.consob.it",
      contatto: "+39 06 8477 1",
    ),
    Emergency(
      titolo: "Centro Antiviolenza",
      icona: "assets/violence.png",
      sito: "https://www.1522.eu",
      contatto: "1522",
    ),
    Emergency(
      titolo: "Numero Unico Emergenze",
      icona: "assets/emergency_call.png",
      sito: "https://112.gov.it",
      contatto: "112",
    ),
    Emergency(
      titolo: "Bambini Scomparsi",
      icona: "assets/kid_help.png",
      sito: "https://www.116000.it",
      contatto: "116000",
    ),
  ];
}
