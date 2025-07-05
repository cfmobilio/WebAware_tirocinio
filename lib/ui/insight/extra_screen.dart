import 'package:flutter/material.dart';
import 'package:pro/ui/insight/viewmodel/extra_viewmodel.dart';
import '../../../models/app_model.dart';
import '../accessibility/tts/tts_page_wrapper.dart';

class ExtraPage extends StatelessWidget {
  final ExtraViewModel viewModel = ExtraViewModel();

  ExtraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argomenti = viewModel.argomenti;
    final mapping = viewModel.argomentiKey;
    return TtsPageWrapper(
        pageTitle: "Sezione Extra",
        pageDescription: "Sei ancora curioso? Questa è la sezione giusta!",
        autoReadTexts: [
        "Scegli una categoria per iniziare",
        "Ogni sezione contiene degli approfondimenti sugli argomenti trattati",
        ],

        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("WebAware", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: argomenti.length,
        itemBuilder: (context, index) {
          final App a = argomenti[index];
          final key = mapping[a.titolo] ?? "altro";

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pushNamed(context, '/insight', arguments: key);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        a.icona,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.titolo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.descrizione,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
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
    ));
  }
}
