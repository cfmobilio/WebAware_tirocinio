// viewmodels/home_viewmodel.dart
import '../../../models/subject_model.dart';

class HomeViewModel {
  final List<Subject> argomentiList = [
    Subject(titolo: 'Privacy online', iconaAsset: 'assets/padlock.png'),
    Subject(titolo: 'Cyberbullismo', iconaAsset: 'assets/warning.png'),
    Subject(titolo: 'Phishing', iconaAsset: 'assets/mail.png'),
    Subject(titolo: 'Dipendenza dai social',iconaAsset: 'assets/hourglass.png'),
    Subject(titolo: 'Fake News',iconaAsset: 'assets/fake.png'),
    Subject(titolo: 'Sicurezza account', iconaAsset: 'assets/shield.png'),
    Subject(titolo: 'Truffe online', iconaAsset: 'assets/scam.png'),
    Subject(titolo: 'Protezione dati', iconaAsset: 'assets/data-security.png'),
    Subject(titolo: 'Netiquette', iconaAsset: 'assets/honesty.png'),
    Subject(titolo: 'Navigazione sicura', iconaAsset: 'assets/online-safety.png')
  ];

  final Map<String, String> argomentiKey = {
    "Privacy online": "privacy",
    "Cyberbullismo": "cyberbullismo",
    "Phishing": "phishing",
    // ...
  };
}
