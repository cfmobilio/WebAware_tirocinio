import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/domanda_model.dart';

class QuestionViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Domanda> domande = [];
  int domandaCorrente = 0;
  int punteggio = 0;
  bool caricamento = true;

  int? rispostaSelezionata;
  String argomento = '';

  Future<void> init(String argomentoKey) async {
    argomento = argomentoKey;
    final snapshot = await _db.collection('quiz_$argomento').get();
    domande = snapshot.docs.map((doc) => Domanda.fromFirestore(doc.data())).toList();
    caricamento = false;
    notifyListeners();
  }

  void selezionaRisposta(int scelta) {
    rispostaSelezionata = scelta;
    notifyListeners();
  }

  void confermaRisposta() {
    if (rispostaSelezionata == domande[domandaCorrente].rispostaCorretta) {
      punteggio++;
    }
    domandaCorrente++;
    rispostaSelezionata = null;
    notifyListeners();
  }

  bool quizFinito() => domandaCorrente >= domande.length;

  Future<void> salvaRisultato(Function(bool successo) onDone) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final percentuale = ((punteggio / domande.length) * 100).toInt();
    final ref = _db.collection("progressi_utente").doc(uid).collection("argomenti").doc(argomento);

    try {
      await ref.set({"percentuale": percentuale});
      if (percentuale >= 80) await _assegnaBadge(uid);
      onDone(true);
    } catch (_) {
      onDone(false);
    }
  }

  Future<void> _assegnaBadge(String uid) async {
    final badgeMap = {
      "privacy": "key",
      "cyberbullismo": "warning",
      "phishing": "target",
      "dipendenza": "hourglass",
      "fake": "fact_check",
      "sicurezza": "shield",
      "truffe": "scam",
      "dati": "floppy_disk",
      "netiquette": "forum",
      "navigazione": "compass",
    };

    final badgeKey = badgeMap[argomento];
    if (badgeKey != null) {
      await _db.collection("users").doc(uid).update({"badges.$badgeKey": true});
    }
  }
}
