import 'package:flutter/material.dart';

class IntermediateResultScreen extends StatelessWidget {
  const IntermediateResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Continua'),
        ),
      ),
    );
  }
}
