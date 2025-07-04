import 'package:flutter/material.dart';
import 'package:pro/ui/quiz/viewmodel/question_viewmodel.dart';
import 'package:provider/provider.dart';

class QAndAScreen extends StatelessWidget {
  final String argomento;
  const QAndAScreen({super.key, required this.argomento});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuestionViewModel()..init(argomento),
      child: Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Consumer<QuestionViewModel>(
          builder: (context, vm, _) {
            if (vm.caricamento) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.quizFinito()) {
              if (!vm.isSaving) {
                vm.isSaving = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  vm.salvaRisultato((successo, percentuale) {
                    vm.isSaving = false;
                    print("[DEBUG] Risultato finale: $percentuale% → ${successo ? 'GOOD' : 'BAD'}");
                    Navigator.pushReplacementNamed(
                      context,
                      successo ? "/good" : "/bad",
                      arguments: percentuale,
                    );
                  });
                });
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Salvataggio in corso..."),
                  ],
                ),
              );
            }

            final domanda = vm.domande[vm.domandaCorrente];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (vm.domandaCorrente + 1) / vm.domande.length,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Domanda ${vm.domandaCorrente + 1} di ${vm.domande.length}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    domanda.testo,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(domanda.opzioni.length, (index) {
                    return RadioListTile<int>(
                      title: Text(domanda.opzioni[index]),
                      value: index,
                      groupValue: vm.rispostaSelezionata,
                      onChanged: (value) => vm.selezionaRisposta(value!),
                    );
                  }),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: vm.rispostaSelezionata != null ? vm.confermaRisposta : null,
                    child: const Text("Conferma"),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
