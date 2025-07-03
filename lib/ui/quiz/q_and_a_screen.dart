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
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Quiz completato!"),
                    ElevatedButton(
                      onPressed: () {
                        vm.salvaRisultato((successo) {
                          Navigator.pushReplacementNamed(context, successo ? "/good" : "/bad");
                        });
                      },
                      child: const Text("Vedi risultato"),
                    )
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
