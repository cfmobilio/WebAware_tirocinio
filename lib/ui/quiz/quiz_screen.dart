import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../accessibility/tts/tts_page_wrapper.dart';

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
    {"titolo": "Protezione dati", "icona": "data-security.png", "key": "dati"},
    {"titolo": "Netiquette", "icona": "honesty.png", "key": "netiquette"},
    {"titolo": "Navigazione sicura", "icona": "online-safety.png", "key": "navigazione"},
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
    return TtsPageWrapper(
      pageTitle: "Sezione Quiz",
      pageDescription: "Testa le tue conoscenze sulla sicurezza informatica",
      autoReadTexts: [
        "Scegli una categoria per iniziare",
        "Ogni quiz contiene domande a risposta multipla",
        "Al termine riceverai un punteggio e feedback dettagliato",
      ],

        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("WebAware", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: quizList.length,
        itemBuilder: (context, index) {
          final quiz = quizList[index];
          final percentuale = progressi[quiz["key"]] ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              leading: Image.asset("assets/${quiz['icona']}", width: 40),
              title: Text(quiz["titolo"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percentuale / 100.0,
                    minHeight: 6,
                    color: Colors.deepOrange,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ],
              ),
              trailing: Text("$percentuale%"),
              onTap: () {
                Navigator.pushNamed(context, '/quiz_domande', arguments: quiz["key"]);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushNamed(context, '/simulation');
              break;
            case 3:
              Navigator.pushNamed(context, '/extra');
              break;
            case 4:
              Navigator.pushNamed(context, '/emergency');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Simulazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'Extra'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Emerg.'),
        ],
      ),
    )
    );
  }
}
