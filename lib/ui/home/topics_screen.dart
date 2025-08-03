import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/viewmodel/auth_viewmodel.dart';
import '../../services/content_viewmodel.dart';
import '../../models/content_model.dart';
import '../level_selector.dart';

class TopicsView extends StatefulWidget {
  const TopicsView({super.key});

  @override
  State<TopicsView> createState() => _TopicsViewState();
}

class _TopicsViewState extends State<TopicsView> {
  String? argomentoKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ottieni l'argomento dai parametri di navigazione
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      argomentoKey = arguments;
      _loadContent();
    }
  }

  void _loadContent() {
    if (argomentoKey == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);

      // Ottieni il livello assegnato dal quiz iniziale
      final userAssignedLevel = int.tryParse(authViewModel.user?.livello ?? '1') ?? 1;

      // Carica il contenuto per questo argomento
      contentViewModel.loadContent(argomentoKey!, userAssignedLevel: userAssignedLevel);
    });
  }

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
    // Controlli di validazione argomenti
    if (argomentoKey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Errore")),
        body: const Center(
          child: Text("Nessun argomento ricevuto dalla navigazione."),
        ),
      );
    }

    return Consumer2<AuthViewModel, ContentViewModel>(
      builder: (context, authViewModel, contentViewModel, child) {
        final userAssignedLevel = int.tryParse(authViewModel.user?.livello ?? '1') ?? 1;

        return Scaffold(
          appBar: AppBar(
            title: contentViewModel.currentContent != null
                ? Text(contentViewModel.currentContent!.titolo)
                : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('info_argomenti')
                  .doc(argomentoKey!)
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
          body: _buildBody(contentViewModel, userAssignedLevel),
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
      },
    );
  }

  Widget _buildBody(ContentViewModel contentViewModel, int userAssignedLevel) {
    // Loading state
    if (contentViewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Caricamento contenuto..."),
          ],
        ),
      );
    }

    // Error state
    if (contentViewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text("Errore: ${contentViewModel.errorMessage}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadContent(),
              child: const Text("Riprova"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Torna indietro"),
            ),
          ],
        ),
      );
    }

    // Content loaded state
    if (contentViewModel.currentContent != null) {
      return _buildContentView(contentViewModel.currentContent!, userAssignedLevel);
    }

    // Fallback to old system if no content is loaded
    return _buildFallbackView();
  }

  Widget _buildContentView(ContentModel content, int userAssignedLevel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Selector
          LevelSelector(
            argomento: argomentoKey!,
            userAssignedLevel: userAssignedLevel,
            onLevelChanged: (newLevel) {
              // Opzionale: feedback quando cambia livello
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Passato al livello ${_getLevelName(newLevel)}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Video section
          if (content.videoUrl != null && content.videoUrl!.isNotEmpty) ...[
            GestureDetector(
              onTap: () => _launchVideo(content.videoUrl!),
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
                  child: getYoutubeThumbnail(content.videoUrl!) != null
                      ? Stack(
                    children: [
                      Image.network(
                        getYoutubeThumbnail(content.videoUrl!)!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

          // Content description
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.titolo,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content.descrizione.isNotEmpty
                            ? content.descrizione
                            : "Nessuna descrizione disponibile.",
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quiz button
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
  }

  Widget _buildFallbackView() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('info_argomenti')
          .doc(argomentoKey!)
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
                  onTap: () => _launchVideo(videoUrl),
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
    );
  }

  Future<void> _launchVideo(String videoUrl) async {
    try {
      final url = Uri.parse(videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossibile aprire il video")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nell'apertura del video: $e")),
        );
      }
    }
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'Elementare';
      case 2:
        return 'Intermedio';
      case 3:
        return 'Avanzato';
      default:
        return 'Livello $level';
    }
  }
}