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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: const Text("WebAware", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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
                children: [
                  Text(
                    "Domanda ${vm.domandaCorrente + 1} / ${vm.domande.length}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    color: const Color(0xFFFD904C),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            domanda.testo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(domanda.opzioni.length, (index) {
                            return RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                domanda.opzioni[index],
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              value: index,
                              groupValue: vm.rispostaSelezionata,
                              activeColor: Colors.white,
                              selectedTileColor: Colors.white,
                              onChanged: (value) => vm.selezionaRisposta(value!),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: vm.domandaCorrente > 0
                            ? () {
                          vm.domandaCorrente--;
                          vm.rispostaSelezionata = null;
                          vm.notifyListeners();
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD904C),
                        ),
                        child: const Text("Indietro", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: vm.rispostaSelezionata != null ? vm.confermaRisposta : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD904C),
                        ),
                        child: const Text("Avanti", style: TextStyle(color: Colors.white)),
                      ),
                    ],
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
