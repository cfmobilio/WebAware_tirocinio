import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pro/ui/accessibility/accessibility_screen.dart';
import 'package:pro/ui/auth/login_screen.dart';
import 'package:pro/ui/emergency/emergency_screen.dart';
import 'package:pro/ui/home/topics_screen.dart';
import 'package:pro/ui/insight/extra_screen.dart';
import 'package:pro/ui/insight/insight_screen.dart';
import 'package:pro/ui/profile/profile_screen.dart';
import 'package:pro/ui/quiz/quiz_screen.dart';
import 'package:pro/ui/simulation/situation_screen.dart';
import 'package:pro/ui/support/support_screen.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/initialtest/quiz_intro_screen.dart';
import 'ui/initialtest/questions_screen.dart';
import 'ui/initialtest/result/base_result_screen.dart';
import 'ui/initialtest/result/intermediate_result_screen.dart';
import 'ui/initialtest/result/advanced_result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WebAwareApp());
}

class WebAwareApp extends StatelessWidget {
  const WebAwareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebAware',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/quizIntro':
            return MaterialPageRoute(builder: (_) => const QuizIntroScreen());
          case '/questions':
            return MaterialPageRoute(builder: (_) => const QuestionsScreen());
          case '/resultBase':
            return MaterialPageRoute(builder: (_) => const BaseResultScreen());
          case '/resultIntermediate':
            return MaterialPageRoute(builder: (_) => const IntermediateResultScreen());
          case '/resultAdvanced':
            return MaterialPageRoute(builder: (_) => const AdvancedResultScreen());
          case '/extra':
            return MaterialPageRoute(builder: (_) => ExtraPage());
          case '/insight':
            return MaterialPageRoute(builder: (_) => const InsightPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/support':
            return MaterialPageRoute(builder: (_) => const SupportPage());
          case '/accessibility':
            return MaterialPageRoute(builder: (_) => const AccessibilityPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeView());
          case '/topics':
            return MaterialPageRoute(builder: (_) => TopicsView());
          case '/quiz':
            return MaterialPageRoute(builder: (_) => QuizPage());
          case '/simulation':
            final argId = settings.arguments;
            if (argId == null || argId is! String) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Nessun ID argomento fornito")),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => SituationScreen(argomentoId: argId),
            );

          case '/emergency':
            return MaterialPageRoute(builder: (_) => EmergencyPage());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
