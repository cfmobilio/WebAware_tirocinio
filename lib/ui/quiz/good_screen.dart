import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GoodPage extends StatelessWidget {
  final String quizId;

  const GoodPage({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ottimo lavoro!")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Hai sbloccato un badge!"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text("Visualizza badge"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz');
              },
              child: const Text("Prossimo quiz"),
            ),
            ElevatedButton(
              onPressed: () {
                Share.share("Ho appena sbloccato un nuovo badge su WebAware! 🥳");
              },
              child: const Text("Condividi"),
            )
          ],
        ),
      ),
    );
  }
}
