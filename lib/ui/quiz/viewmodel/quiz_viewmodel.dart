import 'package:flutter/material.dart';
import '../../../models/quiz_model.dart';

class QuizViewModel extends ChangeNotifier {
  final List<Quiz> _quizList = [
    Quiz(titolo: "Privacy online", icona: Icons.lock),
    Quiz(titolo: "Cyberbullismo", icona: Icons.warning),
    Quiz(titolo: "Phishing", icona: Icons.mail),
    Quiz(titolo: "Dipendenza dai social", icona: Icons.hourglass_empty),
    Quiz(titolo: "Fake News", icona: Icons.fact_check),
    Quiz(titolo: "Sicurezza account", icona: Icons.shield),
    Quiz(titolo: "Truffe online", icona: Icons.wrong_location),
    Quiz(titolo: "Protezione dati", icona: Icons.security),
    Quiz(titolo: "Netiquette", icona: Icons.forum),
    Quiz(titolo: "Navigazione sicura", icona: Icons.navigation),
  ];

  List<Quiz> get quizList => List.unmodifiable(_quizList);

  void aggiornaProgresso(String titolo, int nuovoProgresso) {
    final index = _quizList.indexWhere((q) => q.titolo == titolo);
    if (index != -1) {
      _quizList[index].progressoPercentuale = nuovoProgresso.clamp(0, 100);
      notifyListeners();
    }
  }
}
