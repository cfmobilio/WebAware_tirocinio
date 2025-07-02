import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  String? getYoutubeThumbnail(String url) {
    final uri = Uri.parse(url);
    final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final argomentoKey = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Argomento")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('info_argomenti').doc(argomentoKey).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Argomento non trovato."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final titolo = data['titolo'] ?? "Senza titolo";
          final descrizione = data['descrizione'] ?? "";
          final videoUrl = data['videoUrl'] ?? "";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (videoUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(videoUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Image.network(
                      getYoutubeThumbnail(videoUrl)!,
                      height: 200,
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      descrizione,
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
              Navigator.pushNamed(context, '/profile');
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
    );
  }
}
