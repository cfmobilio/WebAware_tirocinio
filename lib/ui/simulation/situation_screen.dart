import 'package:flutter/material.dart';
import 'package:pro/ui/simulation/viewmodel/simulation_viewmodel.dart';
import 'package:provider/provider.dart';

class SituationScreen extends StatelessWidget {
  final String argomentoId;
  SituationScreen({required this.argomentoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SimulationViewModel()..loadSimulazione(argomentoId),
      child: Consumer<SimulationViewModel>(
        builder: (context, vm, _) {
          if (vm!.isLoading) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final sim = vm.simulazione;
          if (sim == null) return Scaffold(body: Center(child: Text("Errore")));

          return Scaffold(
            appBar: AppBar(title: Text(sim.titolo)),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(sim.descrizione),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _checkRisposta(context, vm, 0),
                    child: Text(sim.scelta[0]),
                  ),
                  ElevatedButton(
                    onPressed: () => _checkRisposta(context, vm, 1),
                    child: Text(sim.scelta[1]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _checkRisposta(BuildContext context, SimulationViewModel vm, int scelta) {
    final feedback = (scelta == vm.simulazione?.rispostaCorretta)
        ? vm.simulazione?.feedbackPositivo
        : vm.simulazione?.feedbackNegativo;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(feedback ?? '')));
  }
}