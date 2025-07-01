import 'package:flutter/material.dart';

class AdvancedResultScreen extends StatelessWidget {
  const AdvancedResultScreen({super.key});

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
