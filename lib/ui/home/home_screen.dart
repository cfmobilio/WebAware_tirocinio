import 'package:flutter/material.dart';
import 'package:pro/ui/home/view_model/home_viewmodel.dart';
import 'package:pro/ui/home/widget/subject_card.dart';
import '../../models/subject_model.dart';
import '../accessibility/tts/tts_page_wrapper.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel vm = HomeViewModel();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return TtsPageWrapper(
        pageTitle: "Sezione informativa",
        pageDescription: "Scopri nuove informazioni e impara!",
        autoReadTexts: [
        "Scegli una categoria per iniziare",
        "Ogni sezione contiene una piccola spiegazione e un video per imparare",
        ],

        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          "WebAware",
          style: TextStyle(color: Colors.white),
        ),
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
        padding: const EdgeInsets.all(8.0),
        itemCount: vm.argomentiList.length,
        itemBuilder: (context, index) {
          Subject subject = vm.argomentiList[index];
          return SubjectCard(
            subject: subject,
            onTap: () {

              final key = vm.getKeyForSubject(subject.titolo);

              try {
                Navigator.pushNamed(
                  context,
                  '/topics',
                  arguments: key,
                );
              } catch (e) {
                print('ERRORE NAVIGAZIONE: $e');
              }

              },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          switch (index) {
            case 0:
            // Già nella home, non fare nulla
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
    ));
  }
}