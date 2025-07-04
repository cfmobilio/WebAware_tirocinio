import 'package:flutter/material.dart';

class BaseResultScreen extends StatelessWidget {
  const BaseResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
          child: const Text('Continua'),
        ),
      ),
    );
  }
}
