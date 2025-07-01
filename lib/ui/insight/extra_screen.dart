import 'package:flutter/material.dart';
import 'package:pro/ui/insight/viewmodel/extra_viewmodel.dart';
import '../../../models/app_model.dart';

class ExtraPage extends StatelessWidget {
  final ExtraViewModel viewModel = ExtraViewModel();

  ExtraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argomenti = viewModel.argomenti;
    final mapping = viewModel.argomentiMap;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Extra"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        itemCount: argomenti.length,
        itemBuilder: (context, index) {
          final App a = argomenti[index];
          return ListTile(
            leading: Image.asset(a.icona, width: 40),
            title: Text(a.titolo),
            subtitle: Text(a.descrizione),
            onTap: () {
              final key = mapping[a.titolo] ?? "altro";
              Navigator.pushNamed(context, '/insight', arguments: key);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/quiz');
              break;
            case 2:
              Navigator.pushNamed(context, '/simulation');
              break;
            case 3:
              Navigator.pushNamed(context, '/extra');
              break;
            case 4:
              Navigator.pushNamed(context, '/emergency');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Simulazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'Extra'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Emerg.'),
        ],
      ),
    );
  }
}
