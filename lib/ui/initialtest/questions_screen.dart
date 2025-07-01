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
      appBar: AppBar(title: Text('Domanda ${_currentIndex + 1}/${_domande.length}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(domanda.testo, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ...List.generate(domanda.opzioni.length, (index) {
            return RadioListTile<int>(
              title: Text(domanda.opzioni[index]),
              value: index,
              groupValue: _selectedOption,
              onChanged: (val) => setState(() => _selectedOption = val),
            );
          }),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                TextButton(onPressed: _previous, child: const Text('Indietro')),
              ElevatedButton(
                onPressed: _selectedOption == null ? null : _next,
                child: Text(_currentIndex == _domande.length - 1 ? 'Fine' : 'Avanti'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
