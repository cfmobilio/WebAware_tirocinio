import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  String? getYoutubeThumbnail(String url) {
    try {
      final uri = Uri.parse(url);
      final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Errore")),
        body: const Center(
          child: Text("Nessun argomento ricevuto dalla navigazione."),
        ),
      );
    }

    if (arguments is! String) {
      return Scaffold(
        appBar: AppBar(title: const Text("Errore")),
        body: Center(
          child: Text("Argomento non valido: tipo ${arguments.runtimeType}"),
        ),
      );
    }

    final argomentoKey = arguments;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('info_argomenti')
              .doc(argomentoKey)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Caricamento...");
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Errore");
            }
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final titolo = data?['titolo'] as String? ?? "Senza titolo";
            return Text(titolo);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('info_argomenti')
            .doc(argomentoKey)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Errore nel caricamento: ${snapshot.error}"),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Torna indietro"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print('Documento non trovato per chiave: $argomentoKey');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("Argomento '$argomentoKey' non trovato."),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Torna indietro"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(
              child: Text("Dati dell'argomento non disponibili."),
            );
          }

          final descrizione = data['descrizione'] as String? ?? "";
          final videoUrl = data['videoUrl'] as String? ?? "";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (videoUrl.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () async {
                      try {
                        final url = Uri.parse(videoUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Impossibile aprire il video")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Errore nell'apertura del video: $e")),
                        );
                      }
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: getYoutubeThumbnail(videoUrl) != null
                            ? Image.network(
                          getYoutubeThumbnail(videoUrl)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
                            ),
                          ),
                        )
                            : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      descrizione.isNotEmpty ? descrizione : "Nessuna descrizione disponibile.",
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/quiz',
                        arguments: argomentoKey,
                      );
                    },
                    icon: const Icon(Icons.quiz),
                    label: const Text("Vai al quiz"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
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
    );
  }
}
