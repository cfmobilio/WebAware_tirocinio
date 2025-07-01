import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pro/ui/accessibility/viewmodel/accesibility_viewmodel.dart';
import '../settings/settings_screen.dart';

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
    viewModel.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: viewModel.loadSettings(),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(title: const Text("Accessibilità")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              children: [
                const Text("Contrasto elevato"),
                const Spacer(),
                Switch(
                  value: viewModel.isHighContrast,
                  onChanged: (value) {
                    setState(() {
                      viewModel.toggleHighContrast(value);
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await tts.speak("Esempio di testo letto da Text to Speech");
              },
              child: const Text("Leggi Testo di Prova"),
            )
          ]),
        ),
      ),
    );
  }
}
