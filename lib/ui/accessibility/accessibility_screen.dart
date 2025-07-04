import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pro/ui/accessibility/viewmodel/accesibility_viewmodel.dart';
import 'package:provider/provider.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  final AccessibilityViewModel viewModel = AccessibilityViewModel();
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AccessibilityViewModel>().loadSettings();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: false,
        title: const Text(
          'Accessibilità',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Alto contrasto"),
              value: viewModel.isHighContrast,
              onChanged: (value) {
                setState(() {
                  viewModel.toggleHighContrast(value);
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Testo ingrandito"),
              value: viewModel.isLargeText,
              onChanged: (value) {
                setState(() {
                  viewModel.toggleLargeText(value);
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  tts.speak("Esempio di testo letto da Text to Speech");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Leggi testo",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
