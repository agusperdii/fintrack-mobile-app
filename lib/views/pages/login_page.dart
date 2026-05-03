import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/register_page.dart';
import 'package:savaio/core/utils/service_locator.dart';

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
        MaterialPageRoute(builder: (_) => const MainLayout()),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SavaioTheme.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SavaioTheme.spacingM),
                Text(
                  'Log in to continue to FinTrack',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SavaioTheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SavaioTheme.spacing3xl),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(SavaioTheme.spacingM),
                    margin: const EdgeInsets.only(bottom: SavaioTheme.spacingL),
                    decoration: BoxDecoration(
                      color: SavaioTheme.errorContainer,
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: SavaioTheme.error),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: SavaioTheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: SavaioTheme.spacingL),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: SavaioTheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: SavaioTheme.spacing2xl),
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SavaioTheme.primary,
                    foregroundColor: SavaioTheme.onPrimaryFixed,
                    padding: const EdgeInsets.symmetric(vertical: SavaioTheme.spacingL),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                    ),
                  ),
                  child: authController.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SavaioTheme.onPrimaryFixed,
                          ),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                const SizedBox(height: SavaioTheme.spacingL),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(color: SavaioTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
