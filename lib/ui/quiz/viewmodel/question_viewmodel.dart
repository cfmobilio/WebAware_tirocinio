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
  bool isSaving = false;

  Future<void> init(String argomentoKey) async {
    argomento = argomentoKey;
    final snapshot = await _db.collection('quiz_$argomento').get();
    domande = snapshot.docs.map((doc) => Domanda.fromFirestore(doc.data())).toList();
    print("[DEBUG] Caricate ${domande.length} domande per l'argomento '$argomento'");
    caricamento = false;
    notifyListeners();
  }

  void selezionaRisposta(int scelta) {
    rispostaSelezionata = scelta;
    notifyListeners();
  }

  void confermaRisposta() {
    final corretta = domande[domandaCorrente].rispostaCorretta;
    print("[DEBUG] Domanda ${domandaCorrente + 1}: scelta=$rispostaSelezionata, corretta=$corretta");

    if (rispostaSelezionata == corretta) {
      punteggio++;
    }

    domandaCorrente++;
    rispostaSelezionata = null;
    notifyListeners();
  }

  bool quizFinito() {
    return domandaCorrente >= domande.length;
  }

  Future<void> salvaRisultato(Function(bool successo, int percentuale) onDone) async {
    final uid = _auth.currentUser?.uid ?? "test_user";
    if (uid == "test_user") {
      print("[WARNING] Utente non autenticato, uso ID fittizio per test.");
    }


    final percentuale = ((punteggio / domande.length) * 100).toInt();
    print("[DEBUG] Punteggio totale: $punteggio/${domande.length} → $percentuale%");

    final ref = _db.collection("progressi_utente").doc(uid).collection("argomenti").doc(argomento);

    try {
      await ref.set({"percentuale": percentuale});
      if (percentuale >= 80) {
        print("[DEBUG] Percentuale >=80%, assegno badge.");
        await _assegnaBadge(uid);
        onDone(true, percentuale);
      } else {
        print("[DEBUG] Percentuale <80%, nessun badge.");
        onDone(false, percentuale);
      }
    } catch (e) {
      print("[ERROR] Errore nel salvataggio: $e");
      onDone(false, percentuale);
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
      print("[DEBUG] Badge '$badgeKey' assegnato.");
    } else {
      print("[DEBUG] Nessun badge corrispondente trovato per '$argomento'");
    }
  }
}
