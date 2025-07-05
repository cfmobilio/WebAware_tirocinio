import 'package:flutter/material.dart';
import '../accessibility/tts/tts_page_wrapper.dart';
import 'splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));
    final isFirst = await _viewModel.isFirstLaunch();

    if (!mounted) return;
    if (isFirst) {
      Navigator.pushReplacementNamed(context, '/quizIntro');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TtsPageWrapper(
        pageTitle: "Splash View",
        pageDescription: "Benvenuto in WebAware",
        autoReadTexts: [
        "Quanto ne sai del mondo di internet?",
        "Scopriamolo!",
        ],

        child: Scaffold(
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'WebAware',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Image.asset('assets/fox_logo.png', height: 200),
          ],
        ),
      ),
    ));
  }
}
