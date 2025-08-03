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

  // Lista dei livelli disponibili per un argomento
  List<int> _availableLevels = [];
  List<int> get availableLevels => _availableLevels;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Carica il contenuto per un argomento specifico
  /// userAssignedLevel: livello assegnato dal quiz iniziale
  Future<void> loadContent(String argomento, {required int userAssignedLevel}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Verifica quali livelli sono disponibili per questo argomento
      await _checkAvailableLevels(argomento);

      // Usa il livello assegnato dall'app come default
      _selectedLevel = userAssignedLevel;

      // Se il livello assegnato non è disponibile, usa il più vicino disponibile
      if (!_availableLevels.contains(_selectedLevel)) {
        // Cerca il livello più vicino disponibile
        _selectedLevel = _findClosestAvailableLevel(userAssignedLevel);
      }

      // Carica il contenuto per il livello selezionato
      await _loadContentForLevel(argomento, _selectedLevel);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Trova il livello disponibile più vicino a quello richiesto
  int _findClosestAvailableLevel(int targetLevel) {
    if (_availableLevels.isEmpty) return 1;

    // Ordina i livelli disponibili per distanza dal target
    _availableLevels.sort((a, b) =>
        (a - targetLevel).abs().compareTo((b - targetLevel).abs()));

    return _availableLevels.first;
  }

  /// Verifica quali livelli sono disponibili per un argomento
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

  /// Carica il contenuto per un livello specifico
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

  /// Cambia TEMPORANEAMENTE il livello di visualizzazione per questo argomento
  /// Questo non modifica il livello base dell'utente
  Future<void> changeLevel(String argomento, int nuovoLivello) async {
    if (!_availableLevels.contains(nuovoLivello)) {
      _errorMessage = 'Livello $nuovoLivello non disponibile per questo argomento';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedLevel = nuovoLivello;
      await _loadContentForLevel(argomento, nuovoLivello);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Ottiene il nome descrittivo del livello
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

  /// Metodo helper per creare contenuti iniziali (da usare una tantum)
  Future<void> createInitialContent() async {
    // Esempio per cyberbullismo
    final Map<String, Map<int, Map<String, dynamic>>> initialContents = {
      'cyberbullismo': {
        1: {
          'titolo': 'Cos\'è il Cyberbullismo?',
          'descrizione': 'Il cyberbullismo è quando qualcuno fa del male ad altri online. Può essere attraverso messaggi cattivi, foto imbarazzanti o escludendo qualcuno da gruppi online. È importante dire sempre a un adulto se qualcuno ti fa del male online.',
          'videoUrl': 'https://www.youtube.com/watch?v=example1'
        },
        2: {
          'titolo': 'Cyberbullismo: Forme e Conseguenze',
          'descrizione': 'Il cyberbullismo è una forma di bullismo digitale che include molestie online, diffamazione, esclusione sociale digitale e cyberstalking. Le conseguenze possono essere gravi: ansia, depressione, isolamento sociale e problemi scolastici. È fondamentale riconoscere i segnali e agire tempestivamente.',
          'videoUrl': 'https://www.youtube.com/watch?v=example2'
        },
        3: {
          'titolo': 'Analisi Approfondita del Cyberbullismo',
          'descrizione': 'Il cyberbullismo rappresenta un fenomeno complesso caratterizzato da aggressioni sistematiche nel cyberspace. Include forme diverse come flaming, harassment, denigration, impersonation, outing & trickery, exclusion e cyberstalking. L\'impatto psicosociale può essere devastante, richiedendo interventi multidisciplinari che coinvolgano scuola, famiglia e servizi specialistici.',
          'videoUrl': 'https://www.youtube.com/watch?v=example3'
        }
      },
      'account': {
        1: {
          'titolo': 'Sicurezza del tuo Account',
          'descrizione': 'Un account sicuro ti protegge online. Usa password diverse e difficili da indovinare. Non condividere mai le tue password con nessuno, neanche con i tuoi amici. Se qualcuno conosce la tua password, può fingere di essere te!',
          'videoUrl': 'https://www.youtube.com/watch?v=example4'
        },
        2: {
          'titolo': 'Gestione Sicura degli Account',
          'descrizione': 'La sicurezza degli account richiede password complesse (12+ caratteri, maiuscole, minuscole, numeri, simboli), autenticazione a due fattori e aggiornamenti regolari. Evita di riutilizzare password e monitora gli accessi sospetti. Mantieni sempre aggiornati dispositivi e applicazioni.',
          'videoUrl': 'https://www.youtube.com/watch?v=example5'
        },
        3: {
          'titolo': 'Sicurezza Account: Approccio Sistemico',
          'descrizione': 'La protezione degli account digitali richiede un approccio olistico che integri crittografia robusta, gestione avanzata delle identità, monitoraggio proattivo delle minacce e implementazione di protocolli di sicurezza Zero Trust. Include analisi comportamentale, threat intelligence e strategie di recovery.',
          'videoUrl': 'https://www.youtube.com/watch?v=example6'
        }
      }
    };

    // Salva i contenuti in Firebase
    for (String argomento in initialContents.keys) {
      for (int livello in initialContents[argomento]!.keys) {
        await _db
            .collection('info_argomenti')
            .doc(argomento)
            .collection('contenuti')
            .doc('livello_$livello')
            .set(initialContents[argomento]![livello]!);
      }
    }
  }
}