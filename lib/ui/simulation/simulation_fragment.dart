import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro/config/api_config.dart';
import '../../data/network/deepseek_api_service.dart';
import 'simulation_viewmodel.dart';
import 'simulation_state.dart';

class FastSimulationFragment extends StatelessWidget {
  final String topic;
  final String level;

  const FastSimulationFragment({
    required this.topic,
    required this.level,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FastSimulationViewModel(
        apiService: OptimizedDeepSeekService(apiKey: ApiConfig.deepSeekApiKey),
      )..loadSimulation(topic, level),
      child: Scaffold(
        appBar: AppBar(
          title: Text("${_getTopicDisplayName(topic)}"),
          backgroundColor: Colors.deepOrange,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Ricarica scenario',
              onPressed: () {
                context.read<FastSimulationViewModel>().loadSimulation(topic, level);
              },
            ),
          ],
        ),
        body: Consumer<FastSimulationViewModel>(
          builder: (context, viewModel, _) {
            final state = viewModel.state;

            if (state is SimulationLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Caricamento scenario...'),
                    SizedBox(height: 8),
                    Text(
                      'Se la connessione è lenta, verrà utilizzato uno scenario offline',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (state is SimulationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        "Errore: ${state.message}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => viewModel.loadSimulation(topic, level),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Riprova'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => viewModel.forceReloadWithRetry(topic, level),
                            icon: const Icon(Icons.wifi_find),
                            label: const Text('Test API'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is SimulationLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge stato
                    const SizedBox(height: 16),
                    // Scenario
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scenario:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.scenario,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Cosa faresti?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Opzioni
                    ...List.generate(state.choices.length, (index) {
                      final choice = state.choices[index];
                      final isSelected = viewModel.selectedChoice == choice;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected ? Colors.blue.shade50 : null,
                        child: ListTile(
                          title: Text(
                            choice,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          leading: Radio<String>(
                            value: choice,
                            groupValue: viewModel.selectedChoice,
                            onChanged: viewModel.hasAnswered == true
                                ? null
                                : (val) {
                              if (val != null) {
                                viewModel.selectChoice(val);
                              }
                            },
                          ),
                          enabled: viewModel.hasAnswered != true,
                        ),
                      );
                    }),

                    // Feedback
                    if (viewModel.selectedChoice != null && viewModel.hasAnswered == true)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.feedback,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Feedback:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getFeedbackForSelectedChoice(state, viewModel),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Pulsanti azione
                    if (viewModel.hasAnswered == true)
                      Container(
                        margin: const EdgeInsets.only(top: 24),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => viewModel.loadSimulation(topic, level),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Nuovo Scenario'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Termina'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _getFeedbackForSelectedChoice(SimulationLoaded state, FastSimulationViewModel viewModel) {
    if (viewModel.selectedChoice == null) return "Feedback non disponibile";

    try {
      final selectedIndex = state.choices.indexOf(viewModel.selectedChoice!);
      if (selectedIndex == -1) return "Feedback non disponibile";

      final feedbackKey = (selectedIndex + 1).toString();
      return state.feedback[feedbackKey] ?? "Feedback non disponibile";
    } catch (e) {
      print('Error getting feedback: $e');
      return "Feedback non disponibile";
    }
  }

  String _getTopicDisplayName(String topic) {
    final Map<String, String> displayNames = {
      'privacy_online': 'Privacy Online',
      'cyberbullismo': 'Cyberbullismo',
      'phishing': 'Phishing',
      'social_media': 'Social Media',
      'fake_news': 'Fake News',
      'sicurezza_account': 'Sicurezza Account',
    };

    return displayNames[topic] ?? topic.replaceAll('_', ' ').toUpperCase();
  }
}