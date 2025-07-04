import 'package:flutter/material.dart';

class AdvancedResultScreen extends StatelessWidget {
  const AdvancedResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Hai raggiunto il livello Avanzato!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
              child: const Text('Continua'),
            ),
          ],
        ),
      ),
    );
  }
}

