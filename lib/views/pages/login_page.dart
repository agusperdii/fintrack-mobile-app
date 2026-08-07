// login_page.dart
// Halaman login pengguna, menangani input email/password dan proses
// autentikasi (termasuk login via Google) melalui AuthController.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/register_page.dart';
import 'package:savaio/views/pages/email_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final authController = context.read<AuthController>();

    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
      return;
    }

    // Tangani jika email belum diverifikasi
    if (authController.error != null && authController.error!.toLowerCase().contains('email not confirmed')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => EmailVerificationPage(email: _emailController.text.trim())),
      );
      return;
    }

    setState(() {
      _errorMessage = authController.error ?? 'Email atau kata sandi salah. Silakan coba lagi.';
    });
  }

  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();
    final authController = context.read<AuthController>();
    final success = await authController.loginWithGoogle();
    if (!mounted) return;
    
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = authController.error ?? 'Gagal masuk dengan Google.';
      });
    }
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String labelText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: SavaioTheme.onSurfaceVariantOf(context),
      ),
      filled: true,
      fillColor: SavaioTheme.surfaceContainerHighOf(context),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SavaioTheme.spacingL,
        vertical: SavaioTheme.spacingL,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
        borderSide: BorderSide(
          color: SavaioTheme.outlineVariantOf(context),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
        borderSide: BorderSide(
          color: SavaioTheme.primaryOf(context),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
        borderSide: BorderSide(
          color: SavaioTheme.errorOf(context),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
        borderSide: BorderSide(
          color: SavaioTheme.errorOf(context),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: SavaioTheme.onSurfaceOf(context),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SavaioTheme.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selamat Datang Kembali',
                  style: textTheme.headlineLarge?.copyWith(
                    color: SavaioTheme.onSurfaceOf(context),
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SavaioTheme.spacingM),
                Text(
                  'Silakan masuk untuk melanjutkan ke Savaio',
                  style: textTheme.bodyMedium?.copyWith(
                    color: SavaioTheme.onSurfaceVariantOf(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SavaioTheme.spacing3xl),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(SavaioTheme.spacingM),
                    margin: const EdgeInsets.only(
                      bottom: SavaioTheme.spacingL,
                    ),
                    decoration: BoxDecoration(
                      color: SavaioTheme.errorOf(context).withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                      border: Border.all(
                        color: SavaioTheme.errorOf(context).withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: SavaioTheme.errorOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  style: TextStyle(
                    color: SavaioTheme.onSurfaceOf(context),
                  ),
                  decoration: _inputDecoration(
                    context,
                    // Tetap menggunakan 'Email' karena sudah umum di UI Indonesia
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: SavaioTheme.spacingL),
                TextField(
                  controller: _passwordController,
                  style: TextStyle(
                    color: SavaioTheme.onSurfaceOf(context),
                  ),
                  decoration: _inputDecoration(
                    context,
                    labelText: 'Kata Sandi',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: SavaioTheme.spacing2xl),
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SavaioTheme.primaryFixedOf(context),
                    foregroundColor: SavaioTheme.onPrimaryFixedOf(context),
                    disabledBackgroundColor:
                        SavaioTheme.surfaceContainerHighestOf(context),
                    disabledForegroundColor:
                        SavaioTheme.onSurfaceVariantOf(context),
                    padding: const EdgeInsets.symmetric(
                      vertical: SavaioTheme.spacingL,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        SavaioTheme.radiusM,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: authController.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SavaioTheme.onPrimaryFixedOf(context),
                          ),
                        )
                      : Text(
                          'Masuk',
                          style: textTheme.labelLarge?.copyWith(
                            color: SavaioTheme.onPrimaryFixedOf(context),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: SavaioTheme.spacingM),
                OutlinedButton.icon(
                  onPressed: authController.isLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SavaioTheme.onSurfaceOf(context),
                    padding: const EdgeInsets.symmetric(
                      vertical: SavaioTheme.spacingL,
                    ),
                    side: BorderSide(
                      color: SavaioTheme.outlineVariantOf(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(
                    'Lanjutkan dengan Google',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: SavaioTheme.spacingL),
                TextButton(
                  onPressed: authController.isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                  child: Text(
                    'Belum punya akun? Daftar sekarang',
                    style: textTheme.bodyMedium?.copyWith(
                      color: SavaioTheme.primaryOf(context),
                      fontWeight: FontWeight.w700,
                    ),
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