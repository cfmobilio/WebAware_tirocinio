import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class OptimizedDeepSeekService {
  final String apiKey;
  final http.Client _client;
  static const String baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxRetries = 2;
  static const int _maxCacheSize = 10;

  static final Map<String, List<Map<String, dynamic>>> _scenarioCache = {};
  static final Set<String> _refillInProgress = {};

  OptimizedDeepSeekService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<void> testApiConnection() async {
    try {
      final response = await _client
          .post(
        Uri.parse(baseUrl),
        headers: _buildHeaders(),
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {"role": "user", "content": "Rispondi solo: TEST OK"}
          ],
          "temperature": 0.1,
          "max_tokens": 50,
        }),
      )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw HttpException('API test failed: ${response.statusCode}');
      }
    } on SocketException {
      rethrow;
    } on TimeoutException {
      rethrow;
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> generateScenarioFast({
    required String topic,
    required String level,
  }) async {
    final cacheKey = '${topic}_$level';

    // Restituisci dalla cache se disponibile
    if (_scenarioCache.containsKey(cacheKey) &&
        _scenarioCache[cacheKey]!.isNotEmpty) {
      final scenario = _scenarioCache[cacheKey]!.removeAt(0);
      _refillCacheInBackground(topic, level);
      return scenario;
    }

    // Genera nuovi scenari
    try {
      final scenarios = await _generateMultipleScenarios(topic, level, count: 3);

      if (scenarios.isEmpty) {
        throw Exception('Nessuno scenario generato');
      }

      // Popola la cache con gli scenari rimanenti
      if (scenarios.length > 1) {
        _scenarioCache[cacheKey] = scenarios.sublist(1);
      }

      // Avvia refill in background
      _refillCacheInBackground(topic, level);

      return scenarios[0];
    } catch (e) {
      rethrow;
    }
  }

  String _buildOptimizedPrompt(String topic, String level, int count) {
    final seed = math.Random().nextInt(100000);
    return '''Genera $count scenari educativi per un pubblico adolescente sul tema "$topic" per livello "$level" .

IMPORTANTE: Rispondi SOLO con un array JSON valido. Non aggiungere testo prima o dopo l'array.

Formato richiesto:
[
  {
    "scenario": "Descrizione dello scenario educativo (2-3 frasi)",
    "choices": ["Prima opzione", "Seconda opzione", "Terza opzione"],
    "feedback": {
      "1": "Feedback per la prima scelta",
      "2": "Feedback per la seconda scelta", 
      "3": "Feedback per la terza scelta"
    }
  }
]

Seed: $seed''';
  }

  Future<List<Map<String, dynamic>>> _generateMultipleScenarios(
      String topic,
      String level, {
        int count = 3,
        int retryCount = 0,
      }) async {
    try {
      final response = await _client
          .post(
        Uri.parse(baseUrl),
        headers: _buildHeaders(),
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {"role": "user", "content": _buildOptimizedPrompt(topic, level, count)}
          ],
          "temperature": 0.7,
          "max_tokens": count * 400,
          "stream": false,
        }),
      )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw HttpException(
            'API error ${response.statusCode}: ${response.reasonPhrase}');
      }

      return _parseScenarios(response.body);
    } on TimeoutException {
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: 2));
        return _generateMultipleScenarios(topic, level, count: count, retryCount: retryCount + 1);
      }
      throw TimeoutException('Request timeout dopo ${_maxRetries + 1} tentativi');
    } on SocketException {
      throw SocketException('Connessione internet assente');
    } catch (e) {
      throw Exception('Errore generazione scenari: $e');
    }
  }

  List<Map<String, dynamic>> _parseScenarios(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      final content = json['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        throw FormatException('Contenuto risposta vuoto');
      }

      // Pulizia più aggressiva del contenuto
      String cleaned = content.trim();

      // Rimuovi markdown code blocks
      cleaned = cleaned.replaceAll(RegExp(r'```json\s*', caseSensitive: false), '');
      cleaned = cleaned.replaceAll(RegExp(r'```\s*', caseSensitive: false), '');

      // Rimuovi commenti HTML
      cleaned = cleaned.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

      // Trova il primo [ e l'ultimo ]
      final startIndex = cleaned.indexOf('[');
      final endIndex = cleaned.lastIndexOf(']');

      if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
        throw FormatException('Array JSON non trovato nella risposta');
      }

      cleaned = cleaned.substring(startIndex, endIndex + 1).trim();

      final data = jsonDecode(cleaned);
      if (data is! List) {
        throw FormatException('Formato non valido: atteso array, ricevuto ${data.runtimeType}');
      }

      if (data.isEmpty) {
        throw FormatException('Array di scenari vuoto');
      }

      return List<Map<String, dynamic>>.from(
          data.map((e) => Map<String, dynamic>.from(e as Map))
      );
    } on FormatException catch (e) {
      throw FormatException('Errore parsing JSON: ${e.message}');
    } catch (e) {
      throw FormatException('Errore parsing risposta: $e');
    }
  }

  void _refillCacheInBackground(String topic, String level) {
    final cacheKey = '${topic}_$level';

    // Evita richieste duplicate
    if (_refillInProgress.contains(cacheKey)) return;

    // Controlla se la cache è già piena
    if ((_scenarioCache[cacheKey]?.length ?? 0) >= _maxCacheSize) return;

    _refillInProgress.add(cacheKey);

    // Esegui in modo non-blocking
    Future.microtask(() async {
      try {
        final newScenarios = await _generateMultipleScenarios(topic, level, count: 3);
        _scenarioCache.putIfAbsent(cacheKey, () => []);
        _scenarioCache[cacheKey]!.addAll(newScenarios);

        // Limita la dimensione della cache
        if (_scenarioCache[cacheKey]!.length > _maxCacheSize) {
          _scenarioCache[cacheKey] =
              _scenarioCache[cacheKey]!.sublist(0, _maxCacheSize);
        }
      } catch (_) {
        // Ignora errori di background refresh
      } finally {
        _refillInProgress.remove(cacheKey);
      }
    });
  }

  Map<String, String> _buildHeaders() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  static void clearCache() {
    _scenarioCache.clear();
    _refillInProgress.clear();
  }
}