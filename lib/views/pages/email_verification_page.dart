// email_verification_page.dart
// Halaman verifikasi email setelah registrasi, menangani input kode OTP
// dan permintaan kirim ulang email verifikasi melalui AuthController.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/views/components/organisms/notifications/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoadingResend = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      AppSnackBar.show(
        context,
        'Kode verifikasi harus 6 digit.',
        type: AppSnackBarType.error,
      );
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.verifyEmailOTP(widget.email, otp);
    
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } else {
      AppSnackBar.show(
        context,
        authController.error ?? 'Verifikasi gagal. Pastikan kode benar.',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _resendEmail() async {
    if (_resendSeconds > 0) return;
    
    setState(() => _isLoadingResend = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        AppSnackBar.show(
          context,
          'Email verifikasi telah dikirim ulang.',
          type: AppSnackBarType.success,
        );
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          'Gagal mengirim ulang email: $e',
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingResend = false);
      }
    }
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 5);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: SavaioTheme.onSurfaceOf(context),
          ),
          onPressed: authController.isLoading 
              ? null 
              : () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SavaioTheme.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SavaioTheme.spacing2xl),
              Icon(
                Icons.mark_email_unread_rounded,
                size: 80,
                color: SavaioTheme.primaryOf(context),
              ),
              const SizedBox(height: SavaioTheme.spacing2xl),
              Text(
                'Verifikasi Email Anda',
                style: textTheme.headlineMedium?.copyWith(
                  color: SavaioTheme.onSurfaceOf(context),
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SavaioTheme.spacingM),
              Text(
                'Kami telah mengirimkan 6 digit kode verifikasi ke:\n${widget.email}',
                style: textTheme.bodyLarge?.copyWith(
                  color: SavaioTheme.onSurfaceVariantOf(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SavaioTheme.spacingXl),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                  color: SavaioTheme.onSurfaceOf(context),
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "••••••",
                  hintStyle: TextStyle(
                    color: SavaioTheme.onSurfaceVariantOf(context).withValues(alpha: 0.5),
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
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  if (val.length == 6) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
              
              const SizedBox(height: SavaioTheme.spacing2xl),

              ElevatedButton(
                onPressed: authController.isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SavaioTheme.primaryFixedOf(context),
                  foregroundColor: SavaioTheme.onPrimaryFixedOf(context),
                  padding: const EdgeInsets.symmetric(
                    vertical: SavaioTheme.spacingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
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
                        'Verifikasi',
                        style: textTheme.labelLarge?.copyWith(
                          color: SavaioTheme.onPrimaryFixedOf(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              
              const SizedBox(height: SavaioTheme.spacingM),

              TextButton(
                onPressed: (_isLoadingResend || authController.isLoading || _resendSeconds > 0) 
                    ? null 
                    : _resendEmail,
                child: _isLoadingResend
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SavaioTheme.primaryOf(context),
                        ),
                      )
                    : Text(
                        _resendSeconds > 0 
                            ? 'Kirim Ulang Kode ($_resendSeconds s)' 
                            : 'Kirim Ulang Kode',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _resendSeconds > 0 
                              ? SavaioTheme.onSurfaceVariantOf(context) 
                              : SavaioTheme.primaryOf(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
