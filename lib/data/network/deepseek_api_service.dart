import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class OptimizedDeepSeekService {
  final String apiKey;
  static const String baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  // Cache per scenari generati
  static final Map<String, List<Map<String, dynamic>>> _scenarioCache = {};

  OptimizedDeepSeekService({required this.apiKey});

  // Test connessione API
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

  // Verifica connessione internet
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('🌐 No internet connection: $e');
      return false;
    }
  }

  // CARICAMENTO VELOCE: restituisce subito uno scenario
  Future<Map<String, dynamic>> generateScenarioFast({
    required String topic,
    required String level,
  }) async {
    final cacheKey = '${topic}_$level';

    print('🔍 Looking for cache key: $cacheKey');
    print('📦 Available cache keys: ${_scenarioCache.keys.toList()}');
    print('📊 Cache sizes: ${_scenarioCache.map((k, v) => MapEntry(k, v.length))}');

    // Se abbiamo scenari in cache, usali
    if (_scenarioCache.containsKey(cacheKey) &&
        _scenarioCache[cacheKey]!.isNotEmpty) {
      final scenario = _scenarioCache[cacheKey]!.removeAt(0);
      print('✅ Using cached scenario from: $cacheKey');
      print('📋 Remaining in cache: ${_scenarioCache[cacheKey]!.length}');

      // Ricarica la cache in background
      _refillCacheInBackground(topic, level);

      return scenario;
    }

    print('❌ No cache found for: $cacheKey');

    // Se non c'è cache, prova a generare immediatamente
    try {
      print('🚀 Generating immediately for: $cacheKey');
      final scenarios = await _generateMultipleScenarios(topic, level, count: 1);
      if (scenarios.isNotEmpty) {
        print('✅ Generated immediate scenario');
        // Avvia generazione in background per riempire la cache
        _generateAndCacheInBackground(topic, level);
        return scenarios.first;
      }
    } catch (e) {
      print('❌ Immediate generation failed: $e');
    }

    // Se tutto fallisce, usa scenario di fallback + genera in background
    print('🔄 Using fallback scenario');
    _generateAndCacheInBackground(topic, level);
    return _getRandomFallbackScenario(topic, level);
  }

  // Pre-caricamento degli scenari più popolari
  Future<void> preloadPopularScenarios() async {
    final popularCombinations = [
      {'topic': 'cyberbullismo', 'level': 'intermedio'},
      {'topic': 'privacy_online', 'level': 'intermedio'},
      {'topic': 'phishing', 'level': 'elementare'},
      {'topic': 'social_media', 'level': 'avanzato'},
      {'topic': 'fake_news', 'level': 'intermedio'},
    ];

    // Test connessione prima di pre-caricare
    await testApiConnection();

    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      print('⚠️ No internet connection - skipping preload');
      return;
    }

    for (final combo in popularCombinations) {
      await _generateAndCacheSync(combo['topic']!, combo['level']!);
      await Future.delayed(Duration(milliseconds: 500)); // Ridotto delay
    }
  }

  // Versione sincrona per il preload
  Future<void> _generateAndCacheSync(String topic, String level) async {
    try {
      print('🔄 Generating scenarios for: $topic - $level');
      final scenarios = await _generateMultipleScenarios(topic, level, count: 3);
      final cacheKey = '${topic}_$level';
      _scenarioCache[cacheKey] = scenarios;
      print('✅ Cached ${scenarios.length} scenarios for: $cacheKey');
    } catch (e) {
      print('❌ Generation error for $topic-$level: $e');
    }
  }

  // Generazione in background
  void _generateAndCacheInBackground(String topic, String level) {
    Future.microtask(() async {
      await _generateAndCacheSync(topic, level);
    });
  }

  void _refillCacheInBackground(String topic, String level) {
    final cacheKey = '${topic}_$level';

    // Ricarica solo se la cache è sotto una certa soglia
    final currentCount = _scenarioCache[cacheKey]?.length ?? 0;
    if (currentCount < 2) {
      print('🔄 Refilling cache for: $cacheKey (current: $currentCount)');
      _generateAndCacheInBackground(topic, level);
    }
  }

  // Metodo per debug della cache
  void debugCache() {
    print('🔍 === CACHE DEBUG ===');
    for (final entry in _scenarioCache.entries) {
      print('📦 ${entry.key}: ${entry.value.length} scenarios');
      if (entry.value.isNotEmpty) {
        print('   First scenario: ${entry.value.first['scenario']?.substring(0, 50)}...');
      }
    }
    print('🔍 === END DEBUG ===');
  }

  // Genera più scenari in una chiamata
  Future<List<Map<String, dynamic>>> _generateMultipleScenarios(
      String topic,
      String level,
      {int count = 3}
      ) async {
    final prompt = _buildOptimizedPrompt(topic, level, count);

    print('🚀 Calling DeepSeek API...');
    print('🔑 API Key: ${apiKey.substring(0, 10)}...');
    print('📝 Prompt length: ${prompt.length}');

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [{"role": "user", "content": prompt}],
          "temperature": 0.8,
          "max_tokens": 2000,
        }),
      ).timeout(const Duration(seconds: 60));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ API call successful');
        final json = jsonDecode(response.body);
        final content = json['choices'][0]['message']['content'];
        print('📝 Generated content length: ${content.length}');

        final parsedScenarios = _parseMultipleScenarios(content);
        if (parsedScenarios != null && parsedScenarios.isNotEmpty) {
          print('✅ Successfully parsed ${parsedScenarios.length} scenarios');
          return parsedScenarios;
        } else {
          print('⚠️ Failed to parse scenarios, using fallback');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
      }
    } catch (e) {
      print('💥 API Exception: $e');
      if (e is SocketException) {
        print('🌐 Network connection problem');
      } else if (e is TimeoutException) {
        print('⏱️ Timeout - DeepSeek not responding in time');
      } else if (e is FormatException) {
        print('📝 JSON parsing error');
      }
    }

    print('🔄 Using fallback scenarios');
    return _generateFallbackScenarios(topic, level, count);
  }

  String _buildOptimizedPrompt(String topic, String level, int count) {
    // Prompt più semplice per livello avanzato
    if (level == 'avanzato') {
      return '''
Genera $count scenari brevi su "$topic" livello avanzato.

JSON:
[
  {
    "scenario": "Scenario breve...",
    "choices": ["A", "B", "C"],
    "feedback": {"1": "Feedback A", "2": "Feedback B", "3": "Feedback C"}
  }
]
''';
    }

    return '''
Genera $count scenari educativi diversi sul tema "$topic" per livello "$level". 

Rispondi SOLO con un array JSON valido (niente altro testo):
[
  {
    "scenario": "Descrizione scenario 1...",
    "choices": ["Opzione A", "Opzione B", "Opzione C"],
    "feedback": {"1": "Feedback per opzione A", "2": "Feedback per opzione B", "3": "Feedback per opzione C"}
  },
  {
    "scenario": "Descrizione scenario 2...",
    "choices": ["Opzione A", "Opzione B", "Opzione C"], 
    "feedback": {"1": "Feedback per opzione A", "2": "Feedback per opzione B", "3": "Feedback per opzione C"}
  }
]
''';
  }

  List<Map<String, dynamic>>? _parseMultipleScenarios(String content) {
    try {
      print('🔍 Parsing API response...');

      // Pulisci il contenuto da eventuali caratteri extra
      String cleanContent = content.trim();

      // Trova l'array JSON
      final arrayMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(cleanContent);
      if (arrayMatch != null) {
        final jsonString = arrayMatch.group(0)!;
        print('📝 Found JSON: ${jsonString.substring(0, math.min(200, jsonString.length))}...');

        final List<dynamic> scenarios = jsonDecode(jsonString);
        final result = scenarios.cast<Map<String, dynamic>>();

        // Valida che ogni scenario abbia i campi necessari
        for (final scenario in result) {
          if (scenario['scenario'] == null ||
              scenario['choices'] == null ||
              scenario['feedback'] == null) {
            print('⚠️ Invalid scenario structure found');
            return null;
          }
        }

        print('✅ Successfully parsed ${result.length} scenarios');
        return result;
      } else {
        print('❌ No JSON array found in response');
      }
    } catch (e) {
      print('❌ Parsing error: $e');
    }
    return null;
  }

  // Scenari di fallback veloci
  Map<String, dynamic> _getRandomFallbackScenario(String topic, String level) {
    final scenarios = _getAllFallbackScenarios()[topic]?[level];
    if (scenarios != null && scenarios.isNotEmpty) {
      final random = Random();
      final selectedScenario = scenarios[random.nextInt(scenarios.length)];
      print('📋 Using fallback scenario for: $topic - $level');
      return selectedScenario;
    }

    print('⚠️ Using generic fallback scenario');
    return {
      'scenario': 'Ti trovi in una situazione online che riguarda ${_getTopicDisplayName(topic)}. Come procedi?',
      'choices': [
        'Agisci con prudenza',
        'Procedi rapidamente',
        'Chiedi aiuto'
      ],
      'feedback': {
        '1': 'Ottima scelta! La prudenza è sempre importante.',
        '2': 'Meglio riflettere prima di agire online.',
        '3': 'Saggia decisione chiedere supporto quando serve.'
      }
    };
  }

  List<Map<String, dynamic>> _generateFallbackScenarios(String topic, String level, int count) {
    final allScenarios = _getAllFallbackScenarios()[topic]?[level] ?? [];

    if (allScenarios.isEmpty) {
      return List.generate(count, (index) => _getRandomFallbackScenario(topic, level));
    }

    final List<Map<String, dynamic>> selected = [];
    final random = Random();

    for (int i = 0; i < count; i++) {
      selected.add(allScenarios[random.nextInt(allScenarios.length)]);
    }

    return selected;
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> _getAllFallbackScenarios() {
    return {
      'cyberbullismo': {
        'elementare': [
          {
            'scenario': 'Un compagno pubblica una foto imbarazzante di te sui social senza permesso. I tuoi amici la vedono e commentano.',
            'choices': ['Lo ignori completamente', 'Parli con un adulto di fiducia', 'Ti vendichi pubblicando una sua foto'],
            'feedback': {
              '1': 'Ignorare può far peggiorare la situazione.',
              '2': 'Perfetto! Un adulto può aiutarti a gestire la situazione.',
              '3': 'La vendetta non risolve il problema, anzi lo peggiora.'
            }
          },
          {
            'scenario': 'Ricevi messaggi offensivi anonimi sui social. Alcuni tuoi amici lo sanno e ti chiedono cosa fare.',
            'choices': ['Blocchi e segnali il profilo', 'Rispondi con insulti', 'Non fai nulla'],
            'feedback': {
              '1': 'Ottima scelta! Bloccare e segnalare ferma il cyberbullismo.',
              '2': 'Rispondere con insulti alimenta il conflitto.',
              '3': 'È importante agire per fermare la situazione.'
            }
          }
        ],
        'intermedio': [
          {
            'scenario': 'Qualcuno ha creato un gruppo chat per insultare un compagno. Ti hanno aggiunto al gruppo e tutti stanno partecipando.',
            'choices': ['Esci dal gruppo e segnali', 'Rimani ma non partecipi', 'Cerchi di convincerli a smettere'],
            'feedback': {
              '1': 'Perfetto! Non essere complice e segnala sempre.',
              '2': 'Rimanere passivi ti rende complice del cyberbullismo.',
              '3': 'Lodevole, ma è importante anche segnalare alle autorità.'
            }
          }
        ],
        'avanzato': [
          {
            'scenario': 'Sei testimone di una campagna coordinata di cyberbullismo contro un compagno. I bulli usano account falsi su più piattaforme.',
            'choices': ['Documenti tutto e segnali alle autorità', 'Cerchi di convincere i bulli privatamente', 'Non ti coinvolgi per sicurezza'],
            'feedback': {
              '1': 'Eccellente! La documentazione è cruciale nei casi gravi.',
              '2': 'Positivo ma insufficiente per fermare azioni coordinate.',
              '3': 'Comprensibile ma il silenzio permette al bullismo di continuare.'
            }
          }
        ]
      },
      'privacy_online': {
        'elementare': [
          {
            'scenario': 'Un nuovo social network ti chiede nome, cognome, telefono, scuola, indirizzo e data di nascita per registrarti.',
            'choices': ['Inserisci tutte le informazioni', 'Inserisci solo quelle necessarie', 'Inventi informazioni false'],
            'feedback': {
              '1': 'Troppo rischioso! Stai condividendo troppi dati personali.',
              '2': 'Perfetto! Condividi solo il minimo necessario.',
              '3': 'Più sicuro che tutto vero, ma meglio essere selettivi con info reali.'
            }
          }
        ],
        'intermedio': [
          {
            'scenario': 'Ricevi una email dal tuo "provider internet" che chiede di verificare il tuo account cliccando un link e inserendo i dati.',
            'choices': ['Clicchi subito e inserisci tutto', 'Verifichi prima chi ha mandato la mail', 'Ignori completamente la mail'],
            'feedback': {
              '1': 'Molto pericoloso! Probabilmente è phishing.',
              '2': 'Ottimo! Sempre verificare la fonte prima di agire.',
              '3': 'Sicuro, ma controlla se è legittimo contattando direttamente il provider.'
            }
          }
        ]
      },
      'phishing': {
        'elementare': [
          {
            'scenario': 'Ricevi un messaggio che dice "Hai vinto 1000€! Clicca qui e inserisci i tuoi dati bancari per ricevere il premio".',
            'choices': ['Clicchi subito per avere i soldi', 'Ti insospettisci e non clicchi', 'Chiedi a un adulto cosa fare'],
            'feedback': {
              '1': 'Molto pericoloso! È chiaramente una truffa.',
              '2': 'Bravo! Il tuo istinto è giusto, è una truffa.',
              '3': 'Ottima idea! Un adulto può confermarti che è una truffa.'
            }
          }
        ],
        'intermedio': [
          {
            'scenario': 'Ricevi una email che sembra venire dalla tua banca chiedendo di verificare urgentemente il tuo account cliccando un link.',
            'choices': ['Clicchi il link immediatamente', 'Controlli l\'indirizzo email del mittente', 'Contatti direttamente la banca'],
            'feedback': {
              '1': 'Molto rischioso! Le banche non chiedono mai dati via email.',
              '2': 'Buona idea! Ma meglio verificare sempre direttamente.',
              '3': 'Perfetto! Sempre contattare direttamente l\'ente ufficiale.'
            }
          }
        ],
        'avanzato': [
          {
            'scenario': 'Ricevi una email sofisticata che replica perfettamente il design del tuo servizio di streaming preferito, chiedendo di aggiornare i dati di pagamento.',
            'choices': ['Inserisci i dati poiché sembra autentica', 'Analizzi attentamente URL e dettagli', 'Accedi direttamente al sito ufficiale'],
            'feedback': {
              '1': 'Pericoloso! I phisher sono sempre più sofisticati.',
              '2': 'Bene! L\'analisi critica è fondamentale.',
              '3': 'Eccellente! Sempre usare i canali ufficiali.'
            }
          },
          {
            'scenario': 'Un collega ti invia un documento importante via email da un indirizzo che sembra il suo, ma chiede credenziali aziendali.',
            'choices': ['Invii le credenziali al collega fidato', 'Verifichi telefonicamente con il collega', 'Segnali alla sicurezza IT'],
            'feedback': {
              '1': 'Molto rischioso! Gli account possono essere compromessi.',
              '2': 'Ottima verifica! Ma informa anche la sicurezza.',
              '3': 'Perfetto! La sicurezza aziendale è prioritaria.'
            }
          }
        ]
      },
      'social_media': {
        'elementare': [
          {
            'scenario': 'Vedi che tutti i tuoi amici postano foto di una festa a cui non sei stato invitato.',
            'choices': ['Commenti negativamente sotto le foto', 'Ne parli con un amico di fiducia', 'Posti una foto per far vedere che ti diverti'],
            'feedback': {
              '1': 'I commenti negativi potrebbero peggiorare la situazione.',
              '2': 'Ottima scelta! Parlare aiuta a gestire le emozioni.',
              '3': 'Fingere di stare bene non risolve come ti senti davvero.'
            }
          }
        ],
        'intermedio': [
          {
            'scenario': 'Un influencer che segui condivide un prodotto "miracoloso" per dimagrire. Tutti i commenti sono positivi.',
            'choices': ['Compri subito il prodotto', 'Cerchi recensioni indipendenti', 'Chiedi consiglio al medico'],
            'feedback': {
              '1': 'Rischioso! Gli influencer sono spesso pagati per promuovere.',
              '2': 'Smart! Le recensioni indipendenti sono più affidabili.',
              '3': 'Perfetto! Il medico è la fonte più sicura per la salute.'
            }
          }
        ],
        'avanzato': [
          {
            'scenario': 'Noti che i tuoi post ricevono sempre meno interazioni. Un servizio ti promette follower e like "reali" a pagamento.',
            'choices': ['Compri follower per aumentare la visibilità', 'Analizzi cosa non funziona nei tuoi contenuti', 'Accetti la diminuzione naturale di engagement'],
            'feedback': {
              '1': 'Controproducente! I follower falsi danneggiano l\'algoritmo.',
              '2': 'Eccellente! L\'analisi è la chiave del miglioramento.',
              '3': 'Saggio, ma puoi sempre migliorare i contenuti autenticamente.'
            }
          }
        ]
      },
      'fake_news': {
        'elementare': [
          {
            'scenario': 'Leggi una notizia scioccante sui social e vuoi condividerla subito.',
            'choices': ['La condividi immediatamente', 'Verifichi prima se è vera', 'La condividi aggiungendo "non so se è vero"'],
            'feedback': {
              '1': 'Pericoloso! Potresti diffondere informazioni false.',
              '2': 'Perfetto! Verifica sempre prima di condividere.',
              '3': 'Meglio di niente, ma è meglio verificare completamente.'
            }
          }
        ],
        'intermedio': [
          {
            'scenario': 'Leggi una notizia su un nuovo studio scientifico da un sito che non conosci. La notizia sembra incredibile.',
            'choices': ['La condividi perché è "scientifica"', 'Cerchi la fonte originale dello studio', 'Verifichi su siti di fact-checking'],
            'feedback': {
              '1': 'Attento! Non tutti gli studi sono validi o ben riportati.',
              '2': 'Ottimo! La fonte primaria è sempre meglio.',
              '3': 'Eccellente! I fact-checker sono molto utili.'
            }
          }
        ],
        'avanzato': [
          {
            'scenario': 'Durante un evento importante, circola una notizia con foto "esclusive". La notizia si diffonde rapidamente.',
            'choices': ['La condividi perché tutti la stanno condividendo', 'Usi strumenti per verificare l\'autenticità delle immagini', 'Aspetti conferme da fonti ufficiali'],
            'feedback': {
              '1': 'Pericoloso! La velocità di diffusione non garantisce la verità.',
              '2': 'Perfetto! Gli strumenti di verifica immagini sono fondamentali.',
              '3': 'Eccellente! Le fonti ufficiali sono più affidabili.'
            }
          }
        ]
      }
    };
  }

  String _getTopicDisplayName(String topic) {
    final names = {
      'privacy_online': 'la privacy online',
      'cyberbullismo': 'il cyberbullismo',
      'phishing': 'il phishing',
      'dipendenza':'Dipendenza dai social',
      'fake_news': 'le fake news',
      'sicurezza_account':'Sicurezza account',
      'truffe_online':'Truffe online',
      'protezione_dati':'Protezione dati',
      'netiquette':'Netiquette',
      'navigazione_sicura':'Navigazione sicura'
    };
    return names[topic] ?? topic;
  }
}