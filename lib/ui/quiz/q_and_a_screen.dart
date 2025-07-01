import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Domanda {
  final String testo;
  final List<String> opzioni;
  final int rispostaCorretta;

  Domanda({required this.testo, required this.opzioni, required this.rispostaCorretta});

  factory Domanda.fromFirestore(Map<String, dynamic> data) {
    return Domanda(
      testo: data['testo'] ?? '',
      opzioni: List<String>.from(data['opzioni'] ?? []),
      rispostaCorretta: data['rispostaCorretta'] ?? 0,
    );
  }
}

class QuizController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Domanda> domande = [];
  int domandaCorrente = 0;
  int punteggio = 0;
  bool caricamento = true;

  String argomento = '';

  void init(String argomentoKey) async {
    argomento = argomentoKey;
    await _ripristinaProgresso();
    await _caricaDomande();
  }

  Future<void> _caricaDomande() async {
    final snapshot = await _db.collection('quiz_$argomento').get();
    domande = snapshot.docs.map((doc) => Domanda.fromFirestore(doc.data())).toList();
    caricamento = false;
    notifyListeners();
  }

  void rispostaUtente(int scelta) {
    if (scelta == domande[domandaCorrente].rispostaCorretta) {
      punteggio++;
    }
    domandaCorrente++;
    notifyListeners();
  }

  void domandaPrecedente() {
    if (domandaCorrente > 0) {
      domandaCorrente--;
      notifyListeners();
    }
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

  Future<void> _ripristinaProgresso() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _db.collection("progressi_utente").doc(uid).collection("argomenti").doc(argomento).get();
    if (doc.exists) {
      domandaCorrente = (doc.data()?["domandaCorrente"] ?? 0);
      punteggio = (doc.data()?["punteggio"] ?? 0);
    }
  }

  Future<void> _assegnaBadge(String uid) async {
    final badgeMap = {
      "cybersecurity": "lock",
      "privacy": "key",
      "social_engineering": "private_detective",
      "dataprotection": "floppy_disk",
      "geopolitics": "earth",
      "phishing": "target",
      "anonymity": "eyes",
      "blocked_content": "banned",
      "navigation": "compass"
    };
    final badgeKey = badgeMap[argomento.toLowerCase().replaceAll(" ", "_")];
    if (badgeKey != null) {
      await _db.collection("users").doc(uid).update({"badges.$badgeKey": true});
    }
  }
}

class QuizDomandePage extends StatefulWidget {
  final String argomento;
  const QuizDomandePage({super.key, required this.argomento});

  @override
  State<QuizDomandePage> createState() => _QuizDomandePageState();
}

class _QuizDomandePageState extends State<QuizDomandePage> {
  final QuizController controller = QuizController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
    controller.init(widget.argomento);
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.caricamento) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.quizFinito()) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Quiz completato!"),
              ElevatedButton(
                onPressed: () {
                  controller.salvaRisultato((successo) {
                    Navigator.pushReplacementNamed(context, successo ? "/good" : "/bad");
                  });
                },
                child: const Text("Vedi risultato"),
              )
            ],
          ),
        ),
      );
    }

    final domanda = controller.domande[controller.domandaCorrente];
    return Scaffold(
      appBar: AppBar(
        title: Text("Domanda ${controller.domandaCorrente + 1}/${controller.domande.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(domanda.testo, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ...List.generate(domanda.opzioni.length, (index) {
              return ListTile(
                title: Text(domanda.opzioni[index]),
                leading: Radio(
                  value: index,
                  groupValue: null,
                  onChanged: (_) {
                    controller.rispostaUtente(index);
                  },
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (controller.domandaCorrente > 0)
                  ElevatedButton(
                    onPressed: controller.domandaPrecedente,
                    child: const Text("Indietro"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
