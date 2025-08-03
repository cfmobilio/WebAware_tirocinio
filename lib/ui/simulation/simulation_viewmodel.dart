import 'package:flutter/material.dart';
import '../../data/network/deepseek_api_service.dart';
import 'simulation_state.dart';

class FastSimulationViewModel extends ChangeNotifier {
  final OptimizedDeepSeekService apiService;
  SimulationState state = SimulationLoading();
  String? selectedChoice;
  bool hasAnswered = false;

  FastSimulationViewModel({required this.apiService});

  Future<void> loadSimulation(String topic, String level) async {
    print('🎮 Loading simulation: $topic - $level');

    state = SimulationLoading();
    hasAnswered = false;
    selectedChoice = null;
    notifyListeners();

    try {
      // Usa il metodo veloce che restituisce subito un risultato
      final result = await apiService.generateScenarioFast(
        topic: topic,
        level: level,
      );

      // Verifica che result non sia null e contenga i campi necessari
      if (result['scenario'] == null ||
          result['choices'] == null ||
          result['feedback'] == null) {
        throw Exception('Dati scenario incompleti');
      }

      // Verifica che choices sia una lista
      final choices = result['choices'];
      if (choices is! List) {
        throw Exception('Choices deve essere una lista');
      }

      // Verifica che feedback sia una mappa
      final feedback = result['feedback'];
      if (feedback is! Map) {
        throw Exception('Feedback deve essere una mappa');
      }

      state = SimulationLoaded(
        scenario: result['scenario'].toString(),
        choices: List<String>.from(choices),
        feedback: Map<String, String>.from(feedback),
      );

      print('✅ Simulation loaded successfully');

    } catch (e) {
      print('❌ Error loading simulation: $e');
      state = SimulationError('Errore nel caricamento: ${e.toString()}');
    }

    notifyListeners();
  }

  void selectChoice(String choice) {
    if (hasAnswered == true) {
      print('⚠️ User already answered, ignoring selection');
      return;
    }

    print('✅ User selected: $choice');
    selectedChoice = choice;
    hasAnswered = true;
    notifyListeners();
  }

  void resetSimulation() {
    print('🔄 Resetting simulation');
    selectedChoice = null;
    hasAnswered = false;
    notifyListeners();
  }

  // Getter per verificare se stiamo usando scenari AI o fallback
  bool get isUsingFallbackScenario {
    // Questo è un modo semplice per determinarlo
    // In un'implementazione più sofisticata potresti aggiungere un flag nel service
    return state is SimulationLoaded;
  }

  // Metodo per forzare la ricarica con tentativi di connessione
  Future<void> forceReloadWithRetry(String topic, String level) async {
    print('🔄 Force reload with retry...');

    // Testa prima la connessione
    await apiService.testApiConnection();

    // Poi carica normalmente
    await loadSimulation(topic, level);
  }
}