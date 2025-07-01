import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  final List<Map<String, dynamic>> quizList = [
    {"titolo": "Privacy online", "icona": "padlock.png", "key": "privacy"},
    {"titolo": "Cyberbullismo", "icona": "warning.png", "key": "cyberbullismo"},
    {"titolo": "Phishing", "icona": "mail.png", "key": "phishing"},
    {"titolo": "Dipendenza dai social", "icona": "hourglass.png", "key": "dipendenza"},
    {"titolo": "Fake News", "icona": "fake.png", "key": "fake"},
    {"titolo": "Sicurezza account", "icona": "shield.png", "key": "sicurezza"},
    {"titolo": "Truffe online", "icona": "scam.png", "key": "truffe"},
    {"titolo": "Protezione dati", "icona": "security.png", "key": "dati"},
    {"titolo": "Netiquette", "icona": "netiquette.png", "key": "netiquette"},
    {"titolo": "Navigazione sicura", "icona": "secure.png", "key": "navigazione"},
  ];

  Map<String, int> progressi = {};

  @override
  void initState() {
    super.initState();
    _caricaProgressi();
  }

  Future<void> _caricaProgressi() async {
    if (uid == null) return;

    final docs = await db.collection("progressi_utente").doc(uid).collection("argomenti").get();

    setState(() {
      for (final d in docs.docs) {
        final percentuale = d.data()["percentuale"] ?? 0;
        progressi[d.id] = (percentuale as num).toInt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: ListView.builder(
        itemCount: quizList.length,
        itemBuilder: (context, index) {
          final quiz = quizList[index];
          final percentuale = progressi[quiz["key"]] ?? 0;

          return ListTile(
            leading: Image.asset("assets/${quiz['icona']}", width: 40),
            title: Text(quiz["titolo"]),
            subtitle: LinearProgressIndicator(
              value: percentuale / 100.0,
              minHeight: 6,
            ),
            trailing: Text("$percentuale%"),
            onTap: () {
              Navigator.pushNamed(context, '/quiz_domande', arguments: quiz["key"]);
            },
          );
        },
      ),
    );
  }
}
