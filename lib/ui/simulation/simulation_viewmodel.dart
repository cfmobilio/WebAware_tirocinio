import 'package:flutter/material.dart';
import '../../data/network/deepseek_api_service.dart';
import 'simulation_state.dart';

class FastSimulationViewModel extends ChangeNotifier {
  final OptimizedDeepSeekService _apiService;

  SimulationState _state = SimulationLoading();
  String? _selectedChoice;
  bool _hasAnswered = false;

  FastSimulationViewModel({required OptimizedDeepSeekService apiService})
      : _apiService = apiService;

  // Getters
  SimulationState get state => _state;
  String? get selectedChoice => _selectedChoice;
  bool get hasAnswered => _hasAnswered;

  bool get isUsingFallbackScenario => _state is SimulationLoaded;

  /// Carica una nuova simulazione per il topic e livello specificati
  Future<void> loadSimulation(String topic, String level) async {
    _resetState();

    try {
      final result = await _apiService.generateScenarioFast(
        topic: topic,
        level: level,
      );

      _validateScenarioResult(result);
      _setState(SimulationLoaded(
        scenario: result['scenario'].toString(),
        choices: List<String>.from(result['choices']),
        feedback: Map<String, String>.from(result['feedback']),
      ));
    } catch (e) {
      _setState(SimulationError('Errore nel caricamento: ${e.toString()}'));
    }
  }

  /// Seleziona una scelta nella simulazione
  void selectChoice(String choice) {
    if (_hasAnswered) return;

    _selectedChoice = choice;
    _hasAnswered = true;
    notifyListeners();
  }

  /// Resetta lo stato della simulazione corrente
  void resetSimulation() {
    _selectedChoice = null;
    _hasAnswered = false;
    notifyListeners();
  }

  /// Forza la ricarica testando prima la connessione API
  Future<void> forceReloadWithRetry(String topic, String level) async {
    try {
      await _apiService.testApiConnection();
      await loadSimulation(topic, level);
    } catch (e) {
      _setState(SimulationError('Errore di connessione: ${e.toString()}'));
    }
  }

  // Metodi privati per la gestione dello stato
  void _resetState() {
    _state = SimulationLoading();
    _hasAnswered = false;
    _selectedChoice = null;
    notifyListeners();
  }

  void _setState(SimulationState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Valida il risultato dello scenario ricevuto dall'API
  void _validateScenarioResult(Map<String, dynamic> result) {
    if (result['scenario'] == null ||
        result['choices'] == null ||
        result['feedback'] == null) {
      throw Exception('Dati scenario incompleti');
    }

    if (result['choices'] is! List) {
      throw Exception('Choices deve essere una lista');
    }

    if (result['feedback'] is! Map) {
      throw Exception('Feedback deve essere una mappa');
    }
  }
}