import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SituationScreen extends StatelessWidget {
  const SituationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments == null || arguments is! String) {
      return Scaffold(
        appBar: AppBar(title: const Text("Errore")),
        body: const Center(child: Text("Nessuna simulazione selezionata.")),
      );
    }

    final simulationId = arguments;

    return Scaffold(
      appBar: AppBar(title: const Text("Simulazione")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('simulazioni')
            .doc(simulationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Simulazione non trovata."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final titolo = data['titolo'] ?? "Senza titolo";
          final descrizione = data['descrizione'] ?? "";
          final scelta = List<String>.from(data['scelta'] ?? []);
          final rispostaCorretta = data['rispostaCorretta'] ?? 0;
          final feedbackPositivo = data['feedbackPositivo'] ?? "Corretto!";
          final feedbackNegativo = data['feedbackNegativo'] ?? "Risposta sbagliata.";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titolo, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text(descrizione),
                const SizedBox(height: 24),
                ...List.generate(scelta.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        final isCorrect = index == rispostaCorretta;
                        final feedback = isCorrect ? feedbackPositivo : feedbackNegativo;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(feedback)));
                      },
                      child: Text(scelta[index]),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
