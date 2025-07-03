import 'package:flutter/material.dart';
import 'package:pro/ui/insight/viewmodel/insight_viewmodel.dart';

class InsightPage extends StatelessWidget {
  const InsightPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String tipo = ModalRoute.of(context)?.settings.arguments as String? ?? "privacy";
    final InsightViewModel viewModel = InsightViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text("Approfondimento")),
      body: FutureBuilder(
        future: viewModel.fetchInsight(tipo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Errore nel caricamento del contenuto."));
          }

          final insight = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.titolo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(insight.descrizione),
              ],
            ),
          );
        },
      ),
    );
  }
}
