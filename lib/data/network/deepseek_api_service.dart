import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class OptimizedDeepSeekService {
  final String apiKey;
  static const String baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  static final Map<String, List<Map<String, dynamic>>> _scenarioCache = {};

  OptimizedDeepSeekService({required this.apiKey});

  Future<void> testApiConnection() async {
    try {
      print('🧪 Testing API connection...');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [{"role": "user", "content": "Rispondi solo: TEST OK"}],
          "temperature": 0.1,
          "max_tokens": 10,
        }),
      ).timeout(const Duration(seconds: 10));

      print('✅ API Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ API Connection successful');
        final json = jsonDecode(response.body);
        print('📝 Response: ${json['choices']?[0]?['message']?['content']}');
      } else {
        print('❌ API Error: ${response.body}');
      }

    } catch (e) {
      print('💥 API Test failed: $e');
      if (e is SocketException) {
        print('🌐 Network connection problem');
      } else if (e is TimeoutException) {
        print('⏱️ API timeout - DeepSeek not responding');
      }
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('🌐 No internet connection: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> generateScenarioFast({
    required String topic,
    required String level,
  }) async {
    final cacheKey = '${topic}_$level';

    print('🔍 Looking for cache key: $cacheKey');
    print('📦 Available cache keys: ${_scenarioCache.keys.toList()}');
    print('📊 Cache sizes: ${_scenarioCache.map((k, v) => MapEntry(k, v.length))}');

    if (_scenarioCache.containsKey(cacheKey) && _scenarioCache[cacheKey]!.isNotEmpty) {
      print('📦 Cache content for $cacheKey: ${_scenarioCache[cacheKey]}');
      final scenario = _scenarioCache[cacheKey]!.removeAt(0);
      print('✅ Using cached scenario from: $cacheKey');
      print('📋 Remaining in cache: ${_scenarioCache[cacheKey]!.length}');

      _refillCacheInBackground(topic, level);
      return scenario;
    }

    print('❌ No cache found for: $cacheKey');

    try {
      print('🚀 Generating immediately for: $cacheKey');
      final scenarios = await _generateMultipleScenarios(topic, level, count: 3);
      if (scenarios.isNotEmpty) {
        print('✅ Generated immediate scenario');
        _generateAndCacheInBackground(topic, level);
        return scenarios[math.Random().nextInt(scenarios.length)];
      }
    } catch (e) {
      print('❌ Immediate generation failed: $e');
    }

    throw Exception('❌ Scenario generation failed and no cache available');
  }

  String _buildOptimizedPrompt(String topic, String level, int count) {
    final seed = math.Random().nextInt(100000);
    return '''
Genera $count scenari educativi diversi sul tema "$topic" per livello "$level".

Rispondi SOLO con un array JSON valido:
[
  {
    "scenario": "Descrizione scenario 1...",
    "choices": ["Opzione A", "Opzione B", "Opzione C"],
    "feedback": {"1": "Feedback per opzione A", "2": "Feedback per opzione B", "3": "Feedback per opzione C"}
  }
]
<!--seed=$seed-->
''';
  }

  Future<List<Map<String, dynamic>>> _generateMultipleScenarios(String topic, String level, {int count = 3}) async {
    final prompt = _buildOptimizedPrompt(topic, level, count);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "deepseek-chat",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7,
        "max_tokens": 800,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final content = json['choices'][0]['message']['content'];

      final cleaned = content
          .replaceAll(RegExp(r'```json', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(cleaned);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }

    throw Exception('❌ Failed to generate or parse scenarios');
  }

  void _generateAndCacheInBackground(String topic, String level) async {
    _refillCacheInBackground(topic, level);
  }

  void _refillCacheInBackground(String topic, String level) async {
    final cacheKey = '${topic}_$level';
    try {
      final newScenarios = await _generateMultipleScenarios(topic, level, count: 3);
      _scenarioCache.putIfAbsent(cacheKey, () => []);
      _scenarioCache[cacheKey]!.addAll(newScenarios);
      print('✅ Cache refilled for $cacheKey (${newScenarios.length} scenarios)');
    } catch (e) {
      print('❌ Background cache refill failed: $e');
    }
  }
}
