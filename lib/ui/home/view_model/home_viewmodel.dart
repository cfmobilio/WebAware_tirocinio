// viewmodels/home_viewmodel.dart
import '../../../models/subject_model.dart';

class HomeViewModel {
  final List<Subject> argomentiList = [
    Subject(titolo: 'Privacy online', iconaAsset: 'assets/padlock.png'),
    Subject(titolo: 'Cyberbullismo', iconaAsset: 'assets/warning.png'),
    Subject(titolo: 'Phishing', iconaAsset: 'assets/mail.png'),
    Subject(titolo: 'Dipendenza dai social', iconaAsset: 'assets/hourglass.png'),
    Subject(titolo: 'Fake News', iconaAsset: 'assets/fake.png'), // Corretto: maiuscola
    Subject(titolo: 'Sicurezza account', iconaAsset: 'assets/shield.png'),
    Subject(titolo: 'Truffe online', iconaAsset: 'assets/scam.png'),
    Subject(titolo: 'Protezione dati', iconaAsset: 'assets/data-security.png'),
    Subject(titolo: 'Netiquette', iconaAsset: 'assets/honesty.png'),
    Subject(titolo: 'Navigazione sicura', iconaAsset: 'assets/online-safety.png')
  ];

  // Mappa corretta con le chiavi che corrispondono ai documenti Firebase
  final Map<String, String> argomentiKey = {
    "Privacy online": "privacy",
    "Cyberbullismo": "cyberbullismo",
    "Phishing": "phishing",
    "Dipendenza dai social": "dipendenza",
    "Fake News": "fake",
    "Sicurezza account": "account",
    "Truffe online": "truffe",
    "Protezione dati": "dati",
    "Netiquette": "netiquette",
    "Navigazione sicura": "navigazione"
  };

  // Metodo helper per ottenere la chiave in modo sicuro
  String getKeyForSubject(String titolo) {
    final key = argomentiKey[titolo];
    if (key == null) {
      print('Attenzione: chiave non trovata per "$titolo"');
      print('Chiavi disponibili: ${argomentiKey.keys.toList()}');
      return "altro"; // Valore di fallback
    }
    return key;
  }

}