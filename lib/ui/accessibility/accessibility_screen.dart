import 'package:flutter/material.dart';
import 'package:pro/ui/accessibility/tts/tts_service.dart';
import 'package:pro/ui/accessibility/viewmodel/accesibility_viewmodel.dart';
import 'package:provider/provider.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<AccessibilityViewModel>().loadSettings();
      await _ttsService.initialize();

      // Leggi automaticamente il contenuto della pagina se l'auto-lettura è abilitata
      if (context.read<AccessibilityViewModel>().isAutoReadEnabled) {
        _ttsService.readPageContent(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityViewModel>(
      builder: (context, viewModel, child) {
        return ListenableBuilder(
          listenable: _ttsService,
          builder: (context, child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Accessibilità'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: "Torna indietro",
                ),
                actions: [
                  // Pulsante per abilitare/disabilitare TTS globale
                  IconButton(
                    icon: Icon(
                      viewModel.isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                    onPressed: () {
                      final newValue = !viewModel.isTtsEnabled;
                      viewModel.toggleTts(newValue);
                      _ttsService.setEnabled(newValue);

                      if (newValue) {
                        _ttsService.speak("Lettura automatica attivata");
                      } else {
                        _ttsService.stop();
                      }
                    },
                    tooltip: viewModel.isTtsEnabled ? "Disabilita lettura" : "Abilita lettura",
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Descrizione della pagina
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: viewModel.isHighContrast ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: viewModel.isHighContrast
                            ? Border.all(color: Colors.yellow, width: 1)
                            : null,
                      ),
                      child: Text(
                        "Personalizza l'accessibilità dell'app per una migliore esperienza d'uso. Attiva la lettura automatica per sentire i contenuti di tutte le pagine.",
                        style: TextStyle(
                          fontSize: viewModel.isLargeText ? 18 : 14,
                          color: viewModel.isHighContrast ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Switch Alto Contrasto
                    SwitchListTile(
                      title: const Text("Alto contrasto"),
                      subtitle: const Text("Migliora la visibilità con colori ad alto contrasto"),
                      value: viewModel.isHighContrast,
                      onChanged: (value) {
                        viewModel.toggleHighContrast(value);
                        if (viewModel.isTtsEnabled) {
                          _ttsService.speak(value ? "Alto contrasto attivato" : "Alto contrasto disattivato");
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Switch Testo Ingrandito
                    SwitchListTile(
                      title: const Text("Testo ingrandito"),
                      subtitle: const Text("Aumenta la dimensione del testo per una migliore leggibilità"),
                      value: viewModel.isLargeText,
                      onChanged: (value) {
                        viewModel.toggleLargeText(value);
                        if (viewModel.isTtsEnabled) {
                          _ttsService.speak(value ? "Testo ingrandito attivato" : "Testo ingrandito disattivato");
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Switch Lettura Vocale
                    SwitchListTile(
                      title: const Text("Lettura vocale"),
                      subtitle: const Text("Abilita la lettura automatica dei contenuti"),
                      value: viewModel.isTtsEnabled,
                      onChanged: (value) {
                        viewModel.toggleTts(value);
                        _ttsService.setEnabled(value);

                        if (value) {
                          _ttsService.speak("Lettura vocale attivata");
                        } else {
                          _ttsService.stop();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Switch Auto-lettura Pagine
                    SwitchListTile(
                      title: const Text("Auto-lettura pagine"),
                      subtitle: const Text("Leggi automaticamente i contenuti quando cambi pagina"),
                      value: viewModel.isAutoReadEnabled,
                      onChanged: viewModel.isTtsEnabled ? (value) {
                        viewModel.toggleAutoRead(value);
                        _ttsService.setAutoReadEnabled(value);

                        if (value) {
                          _ttsService.speak("Auto-lettura delle pagine attivata");
                        } else {
                          _ttsService.speak("Auto-lettura delle pagine disattivata");
                        }
                      } : null, // Disabilita se TTS non è attivo
                    ),
                    const SizedBox(height: 24),

                    // Controlli TTS
                    if (viewModel.isTtsEnabled) ...[
                      Row(
                        children: [
                          // Pulsante Test TTS
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _ttsService.isInitialized ? () {
                                _ttsService.speak("Questa è una prova del sistema di lettura automatica. Da ora in poi, tutti i contenuti dell'app potranno essere letti ad alta voce.");
                              } : null,
                              icon: Icon(
                                _ttsService.isSpeaking ? Icons.volume_up : Icons.record_voice_over,
                              ),
                              label: Text(
                                _ttsService.isSpeaking ? "Lettura..." : "Prova TTS",
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Pulsante Stop
                          if (_ttsService.isSpeaking)
                            ElevatedButton.icon(
                              onPressed: _ttsService.stop,
                              icon: const Icon(Icons.stop),
                              label: const Text("Stop"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stato TTS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: viewModel.isTtsEnabled
                            ? (viewModel.isHighContrast ? Colors.green[900] : Colors.green[50])
                            : (viewModel.isHighContrast ? Colors.grey[900] : Colors.grey[50]),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: viewModel.isTtsEnabled
                              ? (viewModel.isHighContrast ? Colors.green : Colors.green[200]!)
                              : (viewModel.isHighContrast ? Colors.yellow : Colors.grey[300]!),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            viewModel.isTtsEnabled ? Icons.check_circle : Icons.info_outline,
                            color: viewModel.isTtsEnabled
                                ? (viewModel.isHighContrast ? Colors.green : Colors.green[600])
                                : (viewModel.isHighContrast ? Colors.yellow : Colors.grey[600]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.isTtsEnabled ? "Lettura Vocale Attiva" : "Lettura Vocale Disattivata",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: viewModel.isTtsEnabled
                                        ? (viewModel.isHighContrast ? Colors.green : Colors.green[800])
                                        : (viewModel.isHighContrast ? Colors.white : Colors.grey[800]),
                                  ),
                                ),
                                Text(
                                  viewModel.isTtsEnabled
                                      ? "L'app leggerà automaticamente i contenuti di tutte le pagine"
                                      : "Attiva la lettura vocale per sentire i contenuti dell'app",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: viewModel.isTtsEnabled
                                        ? (viewModel.isHighContrast ? Colors.green[200] : Colors.green[600])
                                        : (viewModel.isHighContrast ? Colors.white70 : Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_ttsService.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_outlined, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _ttsService.errorMessage!,
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Padding extra in basso per assicurare che tutto sia visibile
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}