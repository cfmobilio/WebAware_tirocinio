import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../accessibility/tts/tts_page_wrapper.dart';

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
    return TtsPageWrapper(
        pageTitle: "Sezione Supporto",
        pageDescription: "Ci sono dei problemi? Contattaci!",
        autoReadTexts: [
        "In questa sezione puoi contattarci in caso di problemi",
        "Se ti piace l'app puoi lasciarci una recensione",
        "o se hai piacere inviarci un feedback",
        ],

        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          automaticallyImplyLeading: false,
          title: const Text(
            'WebAware',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Image.asset(
                'assets/feedback_illustration.png',
                width: 180,
                height: 180,
              ),

              const SizedBox(height: 24),

              const Text(
                'Hai un problema?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _sendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Contattaci via email',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              const Divider(color: Color(0xFFCCCCCC)),

              const SizedBox(height: 24),

              const Text(
                'Ti piace l\'app? Lascia una recensione!',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                maxRating: 5,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _feedbackController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Scrivi qui il tuo feedback...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _sendFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Invia feedback',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ));
    }
  }
