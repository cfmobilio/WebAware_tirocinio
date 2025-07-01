import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/info_argomento_model.dart';

class TopicsView extends StatelessWidget {
  final Map<String, InfoArgomento> argomenti = {
    "privacy": InfoArgomento(
      titolo: "Privacy online",
      descrizione:
      "La privacy riguarda ciò che condividi di te stesso online. Immagina se tutti conoscessero i tuoi segreti: come ti sentiresti? Purtroppo, alcune persone usano internet per raccogliere informazioni private e approfittarne.\n"
          "Ecco alcune semplici regole per proteggerti:\n"
          " 1. Controlla le impostazioni di privacy: App e social offrono opzioni per limitare ciò che condividi. Scegli sempre quelle che ti permettono di rivelare il minimo possibile.\n"
          " 2. Non usare la stessa password ovunque: Crea password uniche per ogni account e, se possibile, usa l’autenticazione a due fattori.\n"
          " 3. Fai attenzione nelle chat: Parlare online può sembrare informale, ma può essere facile rivelare informazioni sensibili. Pensa due volte prima di condividere.\n"
          "Ricorda, proteggere la tua privacy è un passo fondamentale per navigare in sicurezza.",
      videoUrl: "https://www.youtube.com/watch?v=490QAmZlvTY&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw",
    ),
    "cyberbullismo": InfoArgomento(
      titolo: "Cyberbullismo",
      descrizione:
      "Il cyberbullismo è una forma di bullismo che sfrutta strumenti digitali come social media, email, chat e forum per intimidire, insultare o minacciare una persona.\n"
          "Ecco alcune semplici regole per proteggerti:\n"
          " 1. Interagisci solo con persone che conosci.\n"
          " 2. Fai attenzione agli incontri online.\n"
          " 3. Parla se ti senti a disagio.",
      videoUrl: "https://www.youtube.com/watch?v=w-zlXlzRvOw",
    ),
    "phishing": InfoArgomento(
      titolo: "Phishing",
      descrizione:
      "Il phishing è una frode online in cui un truffatore cerca di ingannarti fingendosi un'entità affidabile per ottenere informazioni sensibili.\n"
          "Ecco alcune regole d’oro per proteggerti:\n"
          " 1. Non condividere mai dati sensibili con sconosciuti.\n"
          " 2. Tieni aggiornati i tuoi dispositivi.\n"
          " 3. Controlla dove acquisti online.",
      videoUrl: "https://www.youtube.com/watch?v=1iPRuIjPuKg&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=2",
    ),
    "dipendenza": InfoArgomento(
      titolo: "Dipendenza dai social",
      descrizione:
      "La dipendenza dai social è un comportamento compulsivo con effetti negativi sulla vita quotidiana.\n"
          "Ecco alcuni consigli utili:\n"
          " 1. Coltiva hobby offline.\n"
          " 2. Limita il tempo sui social.\n"
          " 3. Evita il confronto con gli altri.",
      videoUrl: "https://www.youtube.com/watch?v=TgCk1Fezc8U&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=9",
    ),
    "fake": InfoArgomento(
      titolo: "Fake news",
      descrizione:
      "Le fake news sono informazioni false diffuse per manipolare o creare disinformazione.\n"
          "Come riconoscerle:\n"
          " 1. Collegamento ingannevole.\n"
          " 2. Contenuto ingannatore.\n"
          " 3. Contenuto fuorviante.\n"
          "Verifica sempre le fonti prima di condividere!",
      videoUrl: "https://www.youtube.com/watch?v=pUdvj7AaTVY&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=3",
    ),
    "account": InfoArgomento(
      titolo: "Sicurezza account",
      descrizione:
      "La sicurezza degli account protegge i tuoi dati personali da accessi non autorizzati.\n"
          "Regole d’oro:\n"
          " 1. Usa password complesse e diverse.\n"
          " 2. Attiva l’autenticazione a due fattori.\n"
          " 3. Aggiorna regolarmente dispositivi e app.",
      videoUrl: "https://www.youtube.com/watch?v=fCtLMGod0Ok&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=4",
    ),
    "truffe": InfoArgomento(
      titolo: "Truffe online",
      descrizione:
      "Le truffe online includono phishing, siti falsi, truffe sentimentali.\n"
          "Consigli utili:\n"
          " 1. Non cliccare su link sospetti.\n"
          " 2. Attenzione ai siti troppo convenienti.\n"
          " 3. Diffida da chi chiede soldi online.",
      videoUrl: "https://www.youtube.com/watch?v=vl5B9iE5GQ4&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=8",
    ),
    "dati": InfoArgomento(
      titolo: "Protezione dei dati",
      descrizione:
      "I tuoi dati personali possono essere sfruttati se non li proteggi.\n"
          "Regole base:\n"
          " 1. Condividi con attenzione.\n"
          " 2. Controlla le impostazioni di privacy.\n"
          " 3. Usa solo reti sicure.",
      videoUrl: "https://www.youtube.com/watch?v=AF7Q-ifGr_k&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=6",
    ),
    "netiquette": InfoArgomento(
      titolo: "Netiquette",
      descrizione:
      "La netiquette è il galateo della rete.\n"
          "Regole fondamentali:\n"
          " 1. Rispetta gli altri.\n"
          " 2. Evita contenuti inappropriati.\n"
          " 3. Pensa prima di agire.",
      videoUrl: "https://www.youtube.com/watch?v=Xhr6tWHZU_0&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=5",
    ),
    "navigazione": InfoArgomento(
      titolo: "Navigazione sicura",
      descrizione:
      "Navigare sicuri significa evitare minacce informatiche.\n"
          "Ecco come fare:\n"
          " 1. Usa strumenti anti-malware e browser sicuri.\n"
          " 2. Proteggi la rete Wi-Fi e usa VPN.\n"
          " 3. Aggiorna sistemi e app regolarmente.",
      videoUrl: "https://www.youtube.com/watch?v=7cQq_kO2B0Q&list=PLuJ9q4oR7bZ97NV0tsNILYF9rFG4miXmw&index=7",
    ),
  };

  TopicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final argomentoKey = ModalRoute.of(context)!.settings.arguments as String;
    final contenuto = argomenti[argomentoKey] ?? argomenti['privacy']!;

    String? getYoutubeThumbnail(String url) {
      final uri = Uri.parse(url);
      final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }

    return Scaffold(
      appBar: AppBar(title: Text(contenuto.titolo)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (contenuto.videoUrl.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(contenuto.videoUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Image.network(
                  getYoutubeThumbnail(contenuto.videoUrl)!,
                  height: 200,
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  contenuto.descrizione,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz');
              },
              icon: const Icon(Icons.quiz),
              label: const Text("Vai al quiz"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/profile');
              break;
            case 1:
              Navigator.pushNamed(context, '/home');
              break;
            case 2:
              Navigator.pushNamed(context, '/quiz');
              break;
            case 3:
              Navigator.pushNamed(context, '/simulation');
              break;
            case 4:
              Navigator.pushNamed(context, '/extra');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profilo"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Simulazioni"),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Extra"),
        ],
      ),
    );
  }
}
