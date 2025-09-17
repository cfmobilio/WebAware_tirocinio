import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class InitialTestViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? _tempLevel;

  Future<List<Question>> fetchQuestions() async {
    final snapshot = await _db.collection('quiz_intro').get();
    return snapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
  }

  String getResultRoute(int score) {
    if (score <= 3) return '/resultBase';
    if (score <= 6) return '/resultIntermediate';
    return '/resultAdvanced';
  }

  Future<void> saveUserLevel(BuildContext context, int score, int totalQuestions) async {
    final level = _calculateLevel(score, totalQuestions);

    _tempLevel = level;
  }

  String _calculateLevel(int score, int total) {
    double percentage = score / total;
    if (percentage >= 0.8) return 'avanzato';
    if (percentage >= 0.5) return 'intermedio';
    return 'elementare';
  }

  static String? getTempLevel() => _tempLevel;
  static void clearTempLevel() => _tempLevel = null;
}