import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro/ui/auth/viewmodel/auth_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.deepOrange,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'WebAware',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Image.asset(
              'assets/fox_head.png',
              width: 159,
              height: 198,
            ),

            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                obscureText: true,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 4, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Hai dimenticato la password?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                    await viewModel.login(
                      _emailController.text,
                      _passwordController.text,
                    );

                    if (viewModel.errorMessage == null && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text('LOGIN'),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                    await viewModel.signInWithGoogle();

                    if (viewModel.errorMessage == null && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  icon: viewModel.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Image.asset(
                    'assets/google_logo.png',
                    width: 20,
                    height: 20,
                  ),
                  label: const Text(
                    'Accedi con Google',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepOrange),
                  ),
                ),
              ),
            ),

            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.deepOrange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}