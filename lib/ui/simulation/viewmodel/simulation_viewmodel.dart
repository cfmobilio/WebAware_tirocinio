import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/simulation_model.dart';
import 'package:flutter/material.dart';

class SimulationViewModel extends ChangeNotifier {
  Simulazione? simulazione;
  bool isLoading = false;

  Future<void> loadSimulazione(String idDocumento) async {
    isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance.collection('simulazioni').doc(idDocumento).get();
      if (doc.exists) {
        simulazione = Simulazione.fromMap(doc.id, doc.data()!);
      }
    } catch (e) {
      print('Errore: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}