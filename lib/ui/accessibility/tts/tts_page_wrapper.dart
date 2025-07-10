import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro/ui/accessibility/tts/tts_service.dart';
import 'package:pro/ui/accessibility/viewmodel/accessibility_viewmodel.dart';

class TtsPageWrapper extends StatefulWidget {
  final Widget child;
  final String? pageTitle;
  final String? pageDescription;
  final List<String>? autoReadTexts;

  const TtsPageWrapper({
    super.key,
    required this.child,
    this.pageTitle,
    this.pageDescription,
    this.autoReadTexts,
  });

  @override
  State<TtsPageWrapper> createState() => _TtsPageWrapperState();
}

class _TtsPageWrapperState extends State<TtsPageWrapper> {
  late TtsService _ttsService;
  bool _hasReadContent = false;

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    if (mounted) {
      _scheduleAutoRead();
    }
  }

  void _scheduleAutoRead() {
    final accessibilityViewModel = context.read<AccessibilityViewModel>();

    if (!accessibilityViewModel.isAutoReadEnabled ||
        !accessibilityViewModel.isTtsEnabled ||
        _hasReadContent) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_hasReadContent) {
        _readPageContent();
        _hasReadContent = true;
      }
    });
  }

  void _readPageContent() {
    final accessibilityViewModel = context.read<AccessibilityViewModel>();

    if (!accessibilityViewModel.isTtsEnabled || !accessibilityViewModel.isAutoReadEnabled) {
      return;
    }

    _ttsService.setEnabled(accessibilityViewModel.isTtsEnabled);
    _ttsService.setAutoReadEnabled(accessibilityViewModel.isAutoReadEnabled);

    List<String> textsToRead = [];

    if (widget.pageTitle != null && widget.pageTitle!.isNotEmpty) {
      textsToRead.add(widget.pageTitle!);
    }

    if (widget.pageDescription != null && widget.pageDescription!.isNotEmpty) {
      textsToRead.add(widget.pageDescription!);
    }

    if (widget.autoReadTexts != null && widget.autoReadTexts!.isNotEmpty) {
      textsToRead.addAll(widget.autoReadTexts!);
    }

    if (textsToRead.isEmpty) {
      final route = ModalRoute.of(context)?.settings.name;
      String defaultContent = _getPageContent(route);
      if (defaultContent.isNotEmpty) {
        textsToRead.add(defaultContent);
      }
    }

    if (textsToRead.isNotEmpty) {
      String fullText = textsToRead.join('. ');
      _ttsService.speak(fullText);
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hasReadContent = false;
    if (_ttsService.isInitialized) {
      _scheduleAutoRead();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityViewModel>(
      builder: (context, accessibilityViewModel, child) {
        return ListenableBuilder(
          listenable: _ttsService,
          builder: (context, child) {
            return Stack(
              children: [
                widget.child,

                if (_ttsService.isSpeaking && accessibilityViewModel.isTtsEnabled)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lettura in corso...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_ttsService.isSpeaking && accessibilityViewModel.isTtsEnabled)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: _ttsService.stop,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.stop),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    if (_ttsService.isSpeaking) {
      _ttsService.stop();
    }
    super.dispose();
  }
}