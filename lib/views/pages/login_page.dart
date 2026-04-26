import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'main_screen.dart';
import 'register_page.dart';
import '../../core/utils/service_locator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _handleLogin() async {
    final authController = context.read<AuthController>();
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      if (!mounted) return;
      // Pre-fetch data while transitioning
      sl.financeController.loadInitialData();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid email or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KineticVaultTheme.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KineticVaultTheme.spacingM),
              Text(
                'Log in to continue to FinTrack',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: KineticVaultTheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KineticVaultTheme.spacing3xl),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(KineticVaultTheme.spacingM),
                  margin: const EdgeInsets.only(bottom: KineticVaultTheme.spacingL),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.errorContainer,
                    borderRadius: BorderRadius.circular(KineticVaultTheme.radiusM),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: KineticVaultTheme.error),
                  ),
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: KineticVaultTheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KineticVaultTheme.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: KineticVaultTheme.spacingL),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: KineticVaultTheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KineticVaultTheme.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: KineticVaultTheme.spacing2xl),
              ElevatedButton(
                onPressed: authController.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KineticVaultTheme.primary,
                  foregroundColor: KineticVaultTheme.onPrimaryFixed,
                  padding: const EdgeInsets.symmetric(vertical: KineticVaultTheme.spacingL),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KineticVaultTheme.radiusM),
                  ),
                ),
                child: authController.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: KineticVaultTheme.onPrimaryFixed,
                        ),
                      )
                    : const Text(
                        'Log In',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
              const SizedBox(height: KineticVaultTheme.spacingL),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(color: KineticVaultTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
