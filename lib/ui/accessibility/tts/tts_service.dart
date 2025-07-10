import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isEnabled = false;
  bool _autoReadEnabled = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isEnabled => _isEnabled;
  bool get autoReadEnabled => _autoReadEnabled;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage("it-IT");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        _errorMessage = msg;
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Errore nell'inizializzazione TTS: $e";
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized || !_isEnabled || text.trim().isEmpty) return;

    try {
      if (_isSpeaking) {
        await _tts.stop();
      }
      await _tts.speak(text);
    } catch (e) {
      _errorMessage = "Errore nella lettura: $e";
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
    }
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stop();
    }
    notifyListeners();
  }

  void setAutoReadEnabled(bool enabled) {
    _autoReadEnabled = enabled;
    notifyListeners();
  }

  void readPageContent(BuildContext context) {
    if (!_autoReadEnabled || !_isEnabled) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      final route = ModalRoute.of(context)?.settings.name;
      String pageContent = _getPageContent(route);
      if (pageContent.isNotEmpty) {
        speak(pageContent);
      }
    });
  }

  String _getPageContent(String? routeName) {
    switch (routeName) {
      case '/':
        return "Schermata di avvio dell'applicazione WebAware";
      case '/home':
        return "Schermata principale. Qui puoi accedere a tutte le funzionalità dell'app per migliorare la tua sicurezza online";
      case '/profile':
        return "Profilo utente. Qui puoi vedere e modificare le tue informazioni personali";
      case '/accessibility':
        return "Impostazioni di accessibilità. Personalizza l'app per una migliore esperienza d'uso";
      case '/quiz':
        return "Sezione quiz. Testa le tue conoscenze sulla sicurezza informatica";
      case '/topics':
        return "Argomenti di studio. Approfondisci i temi della sicurezza online";
      case '/simulation':
        return "Simulazioni interattive. Pratica in scenari realistici";
      case '/emergency':
        return "Guida emergenze. Cosa fare in caso di problemi di sicurezza";
      case '/support':
        return "Supporto e assistenza. Ottieni aiuto per l'uso dell'applicazione";
      case '/insight':
        return "Approfondimenti e consigli avanzati sulla sicurezza informatica";
      default:
        return "Navigazione nell'app WebAware";
    }
  }

  void dispose() {
    _tts.stop();
  }
}