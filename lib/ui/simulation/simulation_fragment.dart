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
          title: Text(_getTopicDisplayName(topic)),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
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
              return _buildLoadingState();
            } else if (state is SimulationError) {
              return _buildErrorState(context, viewModel, state);
            } else if (state is SimulationLoaded) {
              return _buildLoadedState(context, viewModel, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Caricamento scenario...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Potrebbe richiedere qualche secondo',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      FastSimulationViewModel viewModel,
      SimulationError state,
      ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Errore",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => viewModel.loadSimulation(topic, level),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Riprova'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => viewModel.forceReloadWithRetry(topic, level),
                  icon: const Icon(Icons.wifi_find),
                  label: const Text('Test API'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
      BuildContext context,
      FastSimulationViewModel viewModel,
      SimulationLoaded state,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Scenario Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.deepOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Scenario:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.scenario,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Cosa faresti?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Choices
          ...List.generate(state.choices.length, (index) {
            final choice = state.choices[index];
            final isSelected = viewModel.selectedChoice == choice;
            final isAnswered = viewModel.hasAnswered == true;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? (isAnswered ? Colors.blue.shade100 : Colors.blue.shade50)
                  : null,
              elevation: isSelected ? 2 : 1,
              child: InkWell(
                onTap: isAnswered
                    ? null
                    : () => viewModel.selectChoice(choice),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: choice,
                        groupValue: viewModel.selectedChoice,
                        onChanged: isAnswered
                            ? null
                            : (val) {
                          if (val != null) {
                            viewModel.selectChoice(val);
                          }
                        },
                        activeColor: Colors.deepOrange,
                      ),
                      Expanded(
                        child: Text(
                          choice,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: isAnswered && !isSelected
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Feedback Card
          if (viewModel.selectedChoice != null && viewModel.hasAnswered == true)
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Card(
                color: Colors.blue.shade50,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.feedback_outlined,
                            color: Colors.blue.shade700,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        _getFeedbackForSelectedChoice(state, viewModel),
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Action Buttons
          if (viewModel.hasAnswered == true)
            Container(
              margin: const EdgeInsets.only(top: 24, bottom: 16),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            viewModel.loadSimulation(topic, level);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Nuovo Scenario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
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
                            foregroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.deepOrange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Pulsante Conferma (quando non ha ancora risposto)
          if (viewModel.selectedChoice != null && viewModel.hasAnswered != true)
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Qui dovresti chiamare il metodo per confermare la risposta
                  // viewModel.confirmAnswer();
                  // Per ora forzo hasAnswered a true
                },
                icon: const Icon(Icons.check),
                label: const Text('Conferma Risposta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFeedbackForSelectedChoice(
      SimulationLoaded state,
      FastSimulationViewModel viewModel,
      ) {
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
      'dipendenza': 'Dipendenza dai Social',
      'truffe_online': 'Truffe Online',
      'protezione_dati': 'Protezione Dati',
      'netiquette': 'Netiquette',
      'navigazione_sicura': 'Navigazione Sicura',
    };

    return displayNames[topic] ??
        topic.replaceAll('_', ' ').split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
  }
}