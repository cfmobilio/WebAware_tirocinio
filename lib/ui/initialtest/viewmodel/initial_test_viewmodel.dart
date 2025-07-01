import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/question_model.dart';

class InitialTestViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Question>> fetchQuestions() async {
    final snapshot = await _db.collection('quiz_intro').get();
    return snapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
  }

  String getResultRoute(int score) {
    if (score <= 3) return '/resultBase';
    if (score <= 6) return '/resultIntermediate';
    return '/resultAdvanced';
  }
}
