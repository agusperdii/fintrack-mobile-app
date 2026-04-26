import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/organisms/app_header.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isSaving = false;
  String? _errorMessage;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (currentPass.isEmpty || newPass.isEmpty) {
      setState(() => _errorMessage = 'Harap isi semua kolom');
      return;
    }

    if (newPass.length < 8) {
      setState(() => _errorMessage = 'Password baru minimal 8 karakter');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() { _isSaving = true; _errorMessage = null; });
    
    final success = await sl.financeController.updatePassword(
      currentPassword: currentPass,
      newPassword: newPass,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diganti'), backgroundColor: KineticVaultTheme.tertiary),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Password lama salah atau terjadi kesalahan.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppHeader(title: 'Ganti Password', showBackButton: true, showNotification: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(
              label: 'Password Sekarang',
              controller: _currentPasswordController,
              obscure: _obscureCurrent,
              onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 20),
            _buildField(
              label: 'Password Baru',
              controller: _newPasswordController,
              obscure: _obscureNew,
              onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 20),
            _buildField(
              label: 'Konfirmasi Password Baru',
              controller: _confirmPasswordController,
              obscure: _obscureNew,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: TextStyle(color: KineticVaultTheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: KineticVaultTheme.primary,
                foregroundColor: KineticVaultTheme.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: KineticVaultTheme.onPrimaryFixed))
                  : Text('UPDATE PASSWORD', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: KineticVaultTheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.inter(color: KineticVaultTheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: KineticVaultTheme.surfaceContainerHigh,
            suffixIcon: onToggleObscure != null 
                ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: KineticVaultTheme.onSurfaceVariant, size: 20),
                    onPressed: onToggleObscure,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: KineticVaultTheme.primary.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
