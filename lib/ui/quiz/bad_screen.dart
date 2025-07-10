import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BadScreen extends StatelessWidget {
  const BadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.deepOrange,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: topPadding + 75,
              padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
              color: Colors.deepOrange,
              alignment: Alignment.centerLeft,
              child: const Text(
                "WebAware",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 32),

            Image.asset('assets/decision_making.png', height: 120),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Hai ancora un po’ di strada da fare",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Vuoi rivedere le domande\no rivedere le nozioni?",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, "/home"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Rivedi le spiegazioni",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, "/quiz"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Riprova il quiz",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
