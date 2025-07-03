import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/insight_model.dart';

class InsightViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Insight?> fetchInsight(String tipo) async {
    try {
      final doc = await _firestore.collection('approfondimenti')
          .doc(tipo)
          .get();
      if (doc.exists) {
        return Insight.fromFirestore(doc.data()!);
      }
    } catch (e) {
      print("Errore nel caricamento di '$tipo': $e");
    }
    return null;
  }
}
