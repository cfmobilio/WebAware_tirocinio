import '../../../models/app_model.dart';

class ExtraViewModel {
  final List<App> argomenti = [
    App(
        titolo: "Privacy online",
        descrizione: "Scopri come proteggere i tuoi dati e la tua identità.",
        icona: "assets/padlock.png"
    ),
    App(
        titolo: "Cyberbullismo",
        descrizione: "Impara a riconoscere e contrastare gli attacchi online.",
        icona: "assets/warning.png"
    ),
    App(
        titolo: "Phishing",
        descrizione: "Riconosci le truffe digitali prima che sia troppo tardi.",
        icona: "assets/mail.png"
    ),
    App(
        titolo: "Dipendenza dai social",
        descrizione: "Scopri come evitare l'uso eccessivo dei social.",
        icona: "assets/hourglass.png"
    ),
    App(
        titolo: "Fake News",
        descrizione: "Impara a riconoscere le notizie false e verificare le fonti online.",
        icona: "assets/fake.png"
    ),
    App(
        titolo: "Sicurezza account",
        descrizione: "Impara a proteggere i tuoi account con password sicure.",
        icona: "assets/shield.png"
    ),
    App(
        titolo: "Truffe online",
        descrizione: "Riconosci le truffe su internet e impara a difenderti.",
        icona: "assets/scam.png"
    ),
    App(
        titolo: "Protezione dati",
        descrizione: "Proteggi i tuoi dati personali online.",
        icona: "assets/data-security.png"
    ),
    App(
        titolo: "Netiquette",
        descrizione: "Rispetta le regole di comportamento online.",
        icona: "assets/honesty.png"
    ),
    App(
        titolo: "Navigazione sicura",
        descrizione: "Naviga in sicurezza proteggendo la tua privacy.",
        icona: "assets/online-safety.png"
    ),
  ];

  final Map<String, String> argomentiKey = {
    "Privacy online": "privacy",
    "Cyberbullismo": "cyberbullismo",
    "Phishing": "phishing",
    "Dipendenza dai social": "dipendenza",
    "Fake News": "fake",
    "Sicurezza account": "sicurezza",
    "Truffe online": "truffe",
    "Protezione dati": "dati",
    "Netiquette": "netiquette",
    "Navigazione sicura": "navigazione",
  };

  String getKeyForSubject(String titolo) {
    final key = argomentiKey[titolo];
    if (key == null) {
      return "altro";
    }
    return key;
  }
}