import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/content_model.dart';

class ContentViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ContentModel? _currentContent;
  ContentModel? get currentContent => _currentContent;

  int _selectedLevel = 1;
  int get selectedLevel => _selectedLevel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<int> _availableLevels = [];
  List<int> get availableLevels => _availableLevels;

  bool _isUpdating = false;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      if (!_isUpdating) {
        notifyListeners();
      }
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      if (!_isUpdating) {
        notifyListeners();
      }
    }
  }

  Future<void> loadContent(String argomento, {required int userAssignedLevel}) async {
    _isUpdating = true;
    _setLoading(true);
    _setError(null);

    try {
      await _checkAvailableLevels(argomento);

      _selectedLevel = userAssignedLevel;

      if (!_availableLevels.contains(_selectedLevel)) {
        _selectedLevel = _findClosestAvailableLevel(userAssignedLevel);
      }

      await _loadContentForLevel(argomento, _selectedLevel);

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _isUpdating = false;
      notifyListeners();
    }
  }

  int _findClosestAvailableLevel(int targetLevel) {
    if (_availableLevels.isEmpty) return 1;

    _availableLevels.sort((a, b) =>
        (a - targetLevel).abs().compareTo((b - targetLevel).abs()));

    return _availableLevels.first;
  }

  Future<void> _checkAvailableLevels(String argomento) async {
    _availableLevels.clear();

    for (int level = 1; level <= 3; level++) {
      final doc = await _db
          .collection('info_argomenti')
          .doc(argomento)
          .collection('contenuti')
          .doc('livello_$level')
          .get();

      if (doc.exists) {
        _availableLevels.add(level);
      }
    }
  }

  // Carica il contenuto per un livello specifico
  Future<void> _loadContentForLevel(String argomento, int livello) async {
    final doc = await _db
        .collection('info_argomenti')
        .doc(argomento)
        .collection('contenuti')
        .doc('livello_$livello')
        .get();

    if (doc.exists) {
      _currentContent = ContentModel.fromMap(doc.data()!, livello);
    } else {
      throw Exception('Contenuto non trovato per il livello $livello');
    }
  }

  // Cambia TEMPORANEAMENTE il livello di visualizzazione per questo argomento
  Future<void> changeLevel(String argomento, int nuovoLivello) async {
    if (!_availableLevels.contains(nuovoLivello)) {
      _setError('Livello $nuovoLivello non disponibile per questo argomento');
      return;
    }

    if (_selectedLevel == nuovoLivello) {
      return;
    }

    _isUpdating = true;
    _setLoading(true);
    _setError(null);

    try {
      _selectedLevel = nuovoLivello;
      await _loadContentForLevel(argomento, nuovoLivello);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _isUpdating = false;
      notifyListeners();
    }
  }

  String getLevelName(int level) {
    switch (level) {
      case 1:
        return 'Elementare';
      case 2:
        return 'Intermedio';
      case 3:
        return 'Avanzato';
      default:
        return 'Livello $level';
    }
  }
}