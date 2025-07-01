import 'package:flutter/material.dart';
import '../../models/argomenti_model.dart';

class SimulationScreen extends StatelessWidget {
  final List<Argomento> argomentiList = [
    Argomento(titolo: "Privacy online", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/padlock.png"),
    Argomento(titolo: "Cyberbullismo", sottotitolo: "Entra nella simulazione!", iconaAssetPath: "assets/warning.png"),
    // ... Altri argomenti ...
  ];

  final Map<String, String> argomentiMap = {
    "Privacy online": "BcKPdRwpCisSdBs8NxSN",
    "Cyberbullismo": "fezFHnyQ22lpHGNVPKUl",
    // ...
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simulazioni')),
      body: ListView.builder(
        itemCount: argomentiList.length,
        itemBuilder: (context, index) {
          final argomento = argomentiList[index];
          return ListTile(
            leading: Image.asset(argomento.iconaAssetPath),
            title: Text(argomento.titolo),
            subtitle: Text(argomento.sottotitolo),
            onTap: () {
              final key = argomentiMap[argomento.titolo] ?? 'altro';
              Navigator.pushNamed(
                context,
                '/situation',
                arguments: key,
              );
            },

          );
        },
      ),
    );
  }
}