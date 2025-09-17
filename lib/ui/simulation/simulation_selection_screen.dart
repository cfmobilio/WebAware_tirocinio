import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SimulationSelectionScreen extends StatefulWidget {
  @override
  _SimulationSelectionScreenState createState() => _SimulationSelectionScreenState();
}

class _SimulationSelectionScreenState extends State<SimulationSelectionScreen> {
  String selectedTopic = 'privacy_online';
  String? userLevel;
  bool isLoadingLevel = true;
  String? errorMessage;

  final Map<String, String> topics = {
    'privacy_online': 'Privacy Online',
    'cyberbullismo': 'Cyberbullismo',
    'phishing': 'Phishing',
    'fake_news': 'Fake News',
    'dipendenza':'Dipendenza dai social',
    'sicurezza_account':'Sicurezza account',
    'truffe_online':'Truffe online',
    'protezione_dati':'Protezione dati',
    'netiquette':'Netiquette',
    'navigazione_sicura':'Navigazione sicura'
  };

  final Map<String, String> levelDisplayNames = {
    'elementare': 'Elementare',
    'intermedio': 'Intermedio',
    'avanzato': 'Avanzato'
  };

  @override
  void initState() {
    super.initState();
    _loadUserLevel();
  }

  Future<void> _loadUserLevel() async {
    try {
      setState(() {
        isLoadingLevel = true;
        errorMessage = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utente non autenticato');
      }


      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Profilo utente non trovato');
      }

      final userData = userDoc.data()!;
      final level = userData['livello'] as String?;

      if (level == null || level.isEmpty) {
        throw Exception('Livello utente non definito');
      }

      // Verifica che il livello sia valido
      if (!levelDisplayNames.containsKey(level)) {
        throw Exception('Livello utente non valido: $level');
      }

      setState(() {
        userLevel = level;
        isLoadingLevel = false;
      });


    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingLevel = false;
      });
    }
  }

  void _startSimulation() {
    if (userLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile avviare la simulazione: livello utente non disponibile'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    Navigator.pushNamed(
      context,
      '/simulation',
      arguments: {
        'topic': selectedTopic,
        'level': userLevel,
      },
    );
  }

  Widget _buildLevelInfo() {
    if (isLoadingLevel) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Caricamento livello utente...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Errore nel caricamento del livello',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red.shade600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadUserLevel,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.school, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Il tuo livello:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade600,
                  ),
                ),
                Text(
                  levelDisplayNames[userLevel!]!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informazioni sul livello utente
            _buildLevelInfo(),

            const SizedBox(height: 24),

            Text(
              'Scegli un argomento:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Dropdown per la selezione del topic
            DropdownButtonFormField<String>(
              value: selectedTopic,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Argomento',
                prefixIcon: Icon(Icons.topic),
              ),
              items: topics.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTopic = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Info sulla simulazione
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Informazioni simulazione',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Argomento: ${topics[selectedTopic]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userLevel != null
                          ? 'Livello: ${levelDisplayNames[userLevel!]}'
                          : 'Livello: Non disponibile',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Pulsante per iniziare la simulazione
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (userLevel != null && !isLoadingLevel)
                    ? _startSimulation
                    : null,
                icon: isLoadingLevel
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  isLoadingLevel
                      ? 'Caricamento...'
                      : 'Inizia Simulazione',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: (userLevel != null && !isLoadingLevel)
                      ? Colors.deepOrangeAccent
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            if (userLevel == null && !isLoadingLevel) ...[
              const SizedBox(height: 8),
              Text(
                'Risolvi il problema del livello utente per continuare',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/quiz');
              break;
            case 2:
            // Già nella schermata simulazioni
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