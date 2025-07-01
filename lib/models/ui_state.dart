import 'package:pro/models/simulation_model.dart';

enum LoadingState { idle, loading, success, error }

class SimulationUiState {
  final LoadingState loadingState;
  final Simulazione? simulazione;
  final String? errorMessage;

  SimulationUiState({
    this.loadingState = LoadingState.idle,
    this.simulazione,
    this.errorMessage,
  });

  SimulationUiState copyWith({
    LoadingState? loadingState,
    Simulazione? simulazione,
    String? errorMessage,
  }) {
    return SimulationUiState(
      loadingState: loadingState ?? this.loadingState,
      simulazione: simulazione ?? this.simulazione,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}