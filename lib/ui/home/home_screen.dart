import 'package:flutter/material.dart';
import 'package:pro/ui/home/view_model/home_viewmodel.dart';
import 'package:pro/ui/home/widget/subject_card.dart';
import '../../models/subject_model.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel vm = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        itemCount: vm.argomentiList.length,
        itemBuilder: (context, index) {
          Subject subject = vm.argomentiList[index];
          return SubjectCard(
            subject: subject,
            onTap: () {
              final key = vm.argomentiKey[subject.titolo] ?? "altro";
              Navigator.pushNamed(context, '/topics', arguments: key);
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
              Navigator.pushNamed(context, '/profile');
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
