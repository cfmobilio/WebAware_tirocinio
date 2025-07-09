import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class GoodPage extends StatelessWidget {
  const GoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.orange, // stesso colore dell'header
        statusBarIconBrightness: Brightness.dark, // icone nere
      ),
    );

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white, // evita la striscia bianca
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER personalizzato con padding per status bar
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

            // Immagine festa
            Image.asset('assets/party_popper.png', height: 120),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Congratulazioni hai compreso tutto!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hai sbloccato un nuovo badge!",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Pulsanti
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Share.share(
                      "Ho appena sbloccato un nuovo badge su WebAware! 🥳",
                    ),
                    icon: Image.asset('assets/share.png', height: 20),
                    label: const Text(
                      "Condividi questo traguardo!",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, "/profile"),
                    child: const Text(
                      "Visualizza il tuo nuovo badge",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, "/quiz"),
                    child: const Text(
                      "Passa al prossimo quiz",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
