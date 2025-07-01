import 'package:flutter/material.dart';

class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/questions');
          },
          child: const Text('Inizia il quiz'),
        ),
      ),
    );
  }
}
