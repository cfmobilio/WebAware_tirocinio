import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class BaseResultScreen extends StatelessWidget {
  const BaseResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/base_level.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text(
              "Il tuo livello:",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Principiante",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Inzia il tuo percorso\nper navigare in modo più sicuro e consapevole!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F3F),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
              child: const Text("Inizia ora"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
