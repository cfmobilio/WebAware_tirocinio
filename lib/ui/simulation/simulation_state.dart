sealed class SimulationState {}

class SimulationLoading extends SimulationState {}

class SimulationLoaded extends SimulationState {
  final String scenario;
  final List<String> choices;
  final Map<String, String> feedback;

  SimulationLoaded({
    required this.scenario,
    required this.choices,
    required this.feedback,
  });
}

class SimulationError extends SimulationState {
  final String message;
  SimulationError(this.message);
}