import 'package:flutter/material.dart';
import 'package:pro/ui/insight/viewmodel/insight_viewmodel.dart';

class InsightPage extends StatelessWidget {
  const InsightPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String tipo = ModalRoute.of(context)?.settings.arguments as String? ?? "privacy";
    final contenuto = InsightViewModel.approfondimenti[tipo];

    return Scaffold(
      appBar: AppBar(title: Text(contenuto?.titolo ?? "Approfondimento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(contenuto?.descrizione ?? "Nessuna descrizione disponibile."),
      ),
    );
  }
}
