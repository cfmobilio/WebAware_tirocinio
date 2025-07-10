import 'package:flutter/material.dart';

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            Center(
              child: Image.asset(
                'assets/fox_logo.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Scopri il tuo livello!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Rispondi ad alcune domande\nper personalizzare il tuo percorso.',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 68.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/questions');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Pronto? Iniziamo!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
