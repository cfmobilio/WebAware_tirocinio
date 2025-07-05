import 'package:flutter/material.dart';
import 'package:pro/ui/emergency/viewmodel/emergency_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../accessibility/tts/tts_page_wrapper.dart';

class EmergencyPage extends StatelessWidget {
  final EmergencyViewModel viewModel = EmergencyViewModel();

  EmergencyPage({super.key});

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Impossibile aprire $url';
  }

  void _launchContact(String contact) async {
    if (contact.contains("@")) {
      final Uri uri = Uri(scheme: "mailto", path: contact);
      if (!await launchUrl(uri)) throw 'Impossibile inviare email a $contact';
    } else {
      final Uri uri = Uri(scheme: "tel", path: contact);
      if (!await launchUrl(uri)) throw 'Impossibile chiamare $contact';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergenze = viewModel.emergenze;

    return TtsPageWrapper(
        pageTitle: "Sezione Contatti",
        pageDescription: "Hai un'emergenza? Questa sezione fa per te!",
        autoReadTexts: [
        "In questa sezione troverai una serie di contatti utili in caso di emergenza",
        "Per ogni contatto è presente il sito web e il numero di telefono",
        ],

        child: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          "WebAware",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: emergenze.length,
        itemBuilder: (context, index) {
          final e = emergenze[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Image.asset(e.icona, width: 40),
              title: Text(e.titolo),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _launchUrl(e.sito),
                    child: Text(e.sito, style: const TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _launchContact(e.contatto),
                    child: Text(e.contatto, style: const TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/quiz');
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
    ));
  }
}
