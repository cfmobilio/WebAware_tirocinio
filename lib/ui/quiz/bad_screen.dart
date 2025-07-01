import 'package:flutter/material.dart';

class BadFragment extends StatelessWidget {
  const BadFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ritenta!"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Text("Non hai superato il quiz...",
              style: TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/quiz"),
            child: const Text("Riprova il quiz"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/profile"),
            child: const Text("Vai al profilo"),
          ),
        ],
      ),
    );
  }
}
