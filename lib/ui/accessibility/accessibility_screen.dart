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
    return Consumer<AccessibilityViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: viewModel.isHighContrast ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: viewModel.isHighContrast ? Colors.black : Colors.deepOrange,
            automaticallyImplyLeading: false,
            title: Text(
              'Accessibilità',
              style: TextStyle(
                fontSize: viewModel.isLargeText ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: viewModel.isHighContrast ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: viewModel.isHighContrast ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(
                    "Alto contrasto",
                    style: TextStyle(
                      fontSize: viewModel.isLargeText ? 20 : 16,
                      color: viewModel.isHighContrast ? Colors.white : Colors.black,
                    ),
                  ),
                  value: viewModel.isHighContrast,
                  onChanged: (value) {
                    viewModel.toggleHighContrast(value);
                  },
                  activeColor: viewModel.isHighContrast ? Colors.yellow : Colors.deepOrange,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    "Testo ingrandito",
                    style: TextStyle(
                      fontSize: viewModel.isLargeText ? 20 : 16,
                      color: viewModel.isHighContrast ? Colors.white : Colors.black,
                    ),
                  ),
                  value: viewModel.isLargeText,
                  onChanged: (value) {
                    viewModel.toggleLargeText(value);
                  },
                  activeColor: viewModel.isHighContrast ? Colors.yellow : Colors.deepOrange,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      tts.speak("Esempio di testo letto da Text to Speech");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: viewModel.isHighContrast ? Colors.yellow : Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Leggi testo",
                      style: TextStyle(
                        color: viewModel.isHighContrast ? Colors.black : Colors.white,
                        fontSize: viewModel.isLargeText ? 20 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}