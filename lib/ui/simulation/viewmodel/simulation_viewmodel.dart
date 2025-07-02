import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/simulation_model.dart';
import 'package:flutter/material.dart';
import '../../../models/argomenti_model.dart';

class SimulationViewModel extends ChangeNotifier {
  final List<Argomento> argomentiList = [
    Argomento(titolo: "Privacy online", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/padlock.png"),
    Argomento(titolo: "Cyberbullismo", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/warning.png"),
    Argomento(titolo: "Phishing", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/mail.png"),
    Argomento(titolo: "Dipendenza dai social", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/hourglass.png"),
    Argomento(titolo: "Fake News", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/fake.png"),
    Argomento(titolo: "Sicurezza account", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/shield.png"),
    Argomento(titolo: "Truffe online", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/scam.png"),
    Argomento(titolo: "Protezione dati", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/data-security.png"),
    Argomento(titolo: "Netiquette", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/honesty.png"),
    Argomento(titolo: "Navigazione sicura", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/online-safety.png"),


  ];

  final Map<String, String> argomentiKey = {
    "Privacy online": "gJgWCSPa5MBYXMfQmtc1",
    "Cyberbullismo": "lH30PTcSfjL0vIiEr3er",
    "Phishing": "jxwPIteFkJ9orjWyzUqc",
    "Dipendenza dai social": "44XbIlDC6QgnyaSDUymb",
    "Fake News": "K0HClxqdyaIxKXJrnPxQ",
    "Sicurezza account": "qOQ56qVTaAZbMZfSf3gV",
    "Truffe online": "eXrpE2Hb9dje0iGJ8Fcy",
    "Protezione dati": "rUIsjgd6V31dMqhA3F2U",
    "Netiquette": "dUGV5FVdBCIoOJGwy01M",
    "Navigazione sicura": "2BJYJOwJyjkkgSupWVCf"
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

  // Metodo per debug - stampa tutte le coppie titolo-chiave
  void debugPrintMappings() {
    print('=== MAPPINGS DEBUG ===');
    for (int i = 0; i < argomentiList.length; i++) {
      final subject = argomentiList[i];
      final key = getKeyForSubject(subject.titolo);
      print('${i + 1}. "${subject.titolo}" -> "$key"');
    }
    print('=====================');
  }

  Simulazione? simulazione;
  bool isLoading = false;

  Future<void> loadSimulazione(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('simulazioni')  // assicurati che il nome collezione sia corretto
          .doc(id)
          .get();

      if (doc.exists) {
        simulazione = Simulazione.fromFirestore(doc);
      } else {
        simulazione = null;
      }
    } catch (e) {
      print("Errore durante il caricamento della simulazione: $e");
      simulazione = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
