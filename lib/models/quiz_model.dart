import 'package:flutter/cupertino.dart';

class Quiz {
  final String titolo;
  final IconData icona;
  int progressoPercentuale;

  Quiz({
    required this.titolo,
    required this.icona,
    this.progressoPercentuale = 0,
  });
}
