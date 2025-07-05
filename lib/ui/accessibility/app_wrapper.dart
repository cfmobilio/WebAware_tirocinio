import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro/ui/accessibility/viewmodel/accessibility_viewmodel.dart';
import 'package:pro/ui/accessibility/tts/tts_page_wrapper.dart';

/// Wrapper principale dell'app che applica automaticamente il TTS a tutte le pagine
class AppWrapper extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext context, Widget child) builder;

  const AppWrapper({
    super.key,
    required this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityViewModel>(
      builder: (context, accessibilityViewModel, child) {
        return MaterialApp(
          title: 'WebAware',
          theme: accessibilityViewModel.getTheme(), // Applica il tema automaticamente
          home: child,
          builder: (context, child) {
            // Wrappa automaticamente ogni pagina con TTS se abilitato
            if (accessibilityViewModel.isTtsEnabled) {
              return TtsPageWrapper(
                child: child ?? Container(),
              );
            }
            return child ?? Container();
          },
        );
      },
    );
  }
}

/// Alternativa: Navigator Observer per controllare le transizioni
class TtsNavigatorObserver extends NavigatorObserver {
  final AccessibilityViewModel accessibilityViewModel;

  TtsNavigatorObserver({required this.accessibilityViewModel});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute);
    }
  }

  void _handleRouteChange(Route<dynamic> route) {
    if (accessibilityViewModel.isTtsEnabled &&
        accessibilityViewModel.isAutoReadEnabled) {
      // Qui puoi aggiungere logica per la lettura automatica
      // basata sul nome della route
      Future.delayed(const Duration(milliseconds: 1000), () {
        // Logica per determinare cosa leggere basandosi sulla route
        String content = _getContentForRoute(route.settings.name);
        if (content.isNotEmpty) {
          // Qui dovresti usare il tuo TtsService per leggere il contenuto
          // _ttsService.speak(content);
        }
      });
    }
  }

  String _getContentForRoute(String? routeName) {
    switch (routeName) {
      case '/':
        return "Schermata di avvio dell'applicazione WebAware";
      case '/home':
        return "Schermata principale. Qui puoi accedere a tutte le funzionalità dell'app";
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
}