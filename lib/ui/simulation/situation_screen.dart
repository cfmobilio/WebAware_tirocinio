import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SituationScreen extends StatefulWidget {
  const SituationScreen({super.key});

  @override
  State<SituationScreen> createState() => _SituationScreenState();
}

class _SituationScreenState extends State<SituationScreen> {
  late Future<DocumentSnapshot> _simulazioneFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! String) {
      _simulazioneFuture = Future.error("Nessuna simulazione selezionata.");
    } else {
      _simulazioneFuture = FirebaseFirestore.instance
          .collection('simulazioni')
          .doc(args)
          .get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _simulazioneFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Simulazione"),
                backgroundColor: Colors.deepOrange,
              ),
              body: const Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Errore"), backgroundColor: Colors.deepOrange),
            body: Center(child: Text("Errore: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text("Errore"), backgroundColor: Colors.deepOrange),
            body: const Center(child: Text("Simulazione non trovata.")),
          );
        }

        final data = snapshot.data!.data()! as Map<String, dynamic>;
        final titolo = data['titolo'] ?? "Senza titolo";
        final descrizione = data['descrizione'] ?? "";
        final feedbackPositivo = data['feedbackPositivo'] ?? "Corretto!";
        final feedbackNegativo = data['feedbackNegativo'] ?? "Risposta sbagliata.";

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            title: const Text("WebAware"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titolo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  color: const Color(0xFFFD904C),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      descrizione,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD904C),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(feedbackNegativo),
                              duration: const Duration(seconds: 10),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text("Sbagliato", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD904C),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(feedbackPositivo),
                              duration: const Duration(seconds: 10),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text("Corretto", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
