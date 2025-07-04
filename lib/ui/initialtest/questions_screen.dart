import 'package:flutter/material.dart';
import 'package:pro/ui/initialtest/viewmodel/initial_test_viewmodel.dart';
import '/models/question_model.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final InitialTestViewModel _viewModel = InitialTestViewModel();
  List<Question> _domande = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    final questions = await _viewModel.fetchQuestions();
    setState(() => _domande = questions);
  }

  void _next() {
    if (_selectedOption == _domande[_currentIndex].rispostaCorretta) {
      _score++;
    }

    if (_currentIndex < _domande.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      final resultRoute = _viewModel.getResultRoute(_score);
      Navigator.pushReplacementNamed(context, resultRoute);
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_domande.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final domanda = _domande[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Titolo domanda (es. "Domanda 1/10")
            Text(
              'Domanda ${_currentIndex + 1}/${_domande.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Card con domanda e opzioni
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 12,
                  color: Colors.white,
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
                            title: Text(
                              domanda.opzioni[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                            value: index,
                            groupValue: _selectedOption,
                            onChanged: (val) => setState(() => _selectedOption = val),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pulsanti "Indietro" e "Avanti"
            Padding(
              padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(
                      onPressed: _previous,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: const TextStyle(fontSize: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('Indietro'),
                    )
                  else
                    const SizedBox(width: 100), // Spazio placeholder

                  ElevatedButton(
                    onPressed: _selectedOption == null ? null : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Text(
                        _currentIndex == _domande.length - 1 ? 'Fine' : 'Avanti'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
