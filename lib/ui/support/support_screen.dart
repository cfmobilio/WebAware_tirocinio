import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0;

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'supporto@example.com',
      query: 'subject=Richiesta di Supporto&body=Ciao, ho bisogno di aiuto con...',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nessuna app email trovata")),
      );
    }
  }

  void _sendFeedback() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Per favore valuta l'app con le stelle")),
      );
    } else if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scrivi un commento prima di inviare")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Grazie per il tuo feedback!")),
      );
      _feedbackController.clear();
      setState(() => _rating = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supporto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          ElevatedButton.icon(
            onPressed: _sendEmail,
            icon: const Icon(Icons.email),
            label: const Text("Contatta il supporto"),
          ),
          const SizedBox(height: 16),
          const Text("Lascia un feedback"),
          Slider(
            min: 0,
            max: 5,
            divisions: 5,
            value: _rating,
            label: _rating.round().toString(),
            onChanged: (value) => setState(() => _rating = value),
          ),
          TextField(
            controller: _feedbackController,
            decoration: const InputDecoration(
              labelText: "Scrivi un commento",
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _sendFeedback,
            child: const Text("Invia Feedback"),
          ),
        ]),
      ),
    );
  }
}
