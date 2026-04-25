import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'main_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  void _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.register(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      // Auto-login after register
      final loginSuccess = await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (loginSuccess && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Email might be taken.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KineticVaultTheme.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KineticVaultTheme.spacingM),
              Text(
                'Join FinTrack today',
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
              const SizedBox(height: KineticVaultTheme.spacingL),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
                onPressed: authController.isLoading ? null : _handleRegister,
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
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
