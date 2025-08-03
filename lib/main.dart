import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pro/services/firebase_notification_service.dart';
import 'package:pro/services/content_viewmodel.dart';
import 'package:pro/ui/accessibility/tts/tts_page_wrapper.dart';
import 'package:pro/ui/accessibility/tts/tts_service.dart';
import 'package:pro/ui/accessibility/viewmodel/accessibility_viewmodel.dart';
import 'package:pro/ui/auth/register_screen.dart';
import 'package:pro/ui/auth/viewmodel/auth_viewmodel.dart';
import 'package:pro/ui/initialtest/welcome_screen.dart';
import 'package:pro/ui/quiz/bad_screen.dart';
import 'package:pro/ui/quiz/good_screen.dart';
import 'package:pro/ui/quiz/q_and_a_screen.dart';
import 'package:provider/provider.dart';
import 'package:pro/ui/simulation/simulation_fragment.dart';
import 'package:pro/ui/simulation/simulation_selection_screen.dart';
import 'package:pro/ui/profile/viewmodel/profile_viewmodel.dart';

import 'package:pro/ui/accessibility/accessibility_screen.dart';
import 'package:pro/ui/auth/login_screen.dart';
import 'package:pro/ui/emergency/emergency_screen.dart';
import 'package:pro/ui/home/topics_screen.dart';
import 'package:pro/ui/insight/extra_screen.dart';
import 'package:pro/ui/insight/insight_screen.dart';
import 'package:pro/ui/profile/profile_screen.dart';
import 'package:pro/ui/quiz/quiz_screen.dart';
import 'package:pro/ui/support/support_screen.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/initialtest/quiz_intro_screen.dart';
import 'ui/initialtest/questions_screen.dart';
import 'ui/initialtest/result/base_result_screen.dart';
import 'ui/initialtest/result/intermediate_result_screen.dart';
import 'ui/initialtest/result/advanced_result_screen.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseNotificationService().initialize();

  FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

  runApp(const WebAwareApp());
}

class WebAwareApp extends StatelessWidget {
  const WebAwareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ContentViewModel()),
        ChangeNotifierProvider(
          create: (_) => AccessibilityViewModel()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => TtsService()..initialize()),
      ],
      child: Consumer<AccessibilityViewModel>(
        builder: (context, accessibilityViewModel, child) {
          return MaterialApp(
            title: 'WebAware',
            debugShowCheckedModeBanner: false,
            theme: accessibilityViewModel.getTheme(),
            builder: (context, child) {
              if (accessibilityViewModel.isTtsEnabled) {
                return TtsPageWrapper(
                  child: child ?? Container(),
                );
              }
              return child ?? Container();
            },
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

                case '/welcome':
                  return MaterialPageRoute(builder: (_) => const WelcomeScreen());

                case '/extra':
                  return MaterialPageRoute(builder: (_) => ExtraPage());

                case '/insight':
                  return MaterialPageRoute(builder: (_) => const InsightPage());

                case '/login':
                  return MaterialPageRoute(builder: (_) => LoginScreen());

                case '/register':
                  return MaterialPageRoute(builder: (_) => RegisterScreen());

                case '/support':
                  return MaterialPageRoute(builder: (_) => const SupportPage());

                case '/accessibility':
                  return MaterialPageRoute(builder: (_) => const AccessibilityPage());

                case '/profile':
                  return MaterialPageRoute(builder: (_) => const ProfilePage());

                case '/home':
                  return MaterialPageRoute(builder: (_) => HomeView());

                case '/topics':
                  return MaterialPageRoute(
                    builder: (_) => const TopicsView(),
                    settings: settings,
                  );

                case '/quiz':
                  return MaterialPageRoute(builder: (_) => QuizPage());

                case '/quiz_domande':
                  final arg = settings.arguments as String;
                  return MaterialPageRoute(builder: (_) => QAndAScreen(argomento: arg));

                case '/good':
                  return MaterialPageRoute(builder: (_) => GoodPage());

                case '/bad':
                  return MaterialPageRoute(builder: (_) => BadScreen());

                case '/simulation':
                  final args = settings.arguments as Map<String, dynamic>?;

                  if (args == null) {
                    return MaterialPageRoute(
                      builder: (_) => SimulationSelectionScreen(),
                    );
                  }

                  return MaterialPageRoute(
                    builder: (_) => FastSimulationFragment(
                      topic: args['topic'] as String,
                      level: args['level'] as String,
                    ),
                  );

                case '/emergency':
                  return MaterialPageRoute(builder: (_) => EmergencyPage());

                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}