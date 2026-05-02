import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/organisms/app_header.dart';

class ChangeUsernamePage extends StatefulWidget {
  final String currentUsername;
  final String currentFullName;
  const ChangeUsernamePage({super.key, required this.currentUsername, required this.currentFullName});

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  late final TextEditingController _usernameController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final username = _usernameController.text.trim().toLowerCase();
    if (username.isEmpty) {
      setState(() => _errorMessage = 'Username tidak boleh kosong');
      return;
    }
    
    // Simple validation: alphanumeric and underscores only
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      setState(() => _errorMessage = 'Username hanya boleh berisi huruf kecil, angka, dan underscore');
      return;
    }

    setState(() { _isSaving = true; _errorMessage = null; });
    
    // We update both because updateProfile expects fullName
    final success = await sl.financeController.updateProfile(
      fullName: widget.currentFullName,
      username: username,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username berhasil diperbarui'), backgroundColor: SavaioTheme.tertiary),
        );
        Navigator.pop(context, true);
      } else {
        setState(() => _errorMessage = 'Username sudah digunakan atau gagal diperbarui.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: AppHeader(title: 'Ganti Username', showBackButton: true, showNotification: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text('Username Baru', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: SavaioTheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              autofocus: true,
              style: GoogleFonts.inter(color: SavaioTheme.onSurface),
              decoration: InputDecoration(
                prefixText: '@ ',
                prefixStyle: TextStyle(color: SavaioTheme.primary, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: SavaioTheme.surfaceContainerHigh,
                hintText: 'user_anda',
                hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SavaioTheme.primary.withValues(alpha: 0.5)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Username akan digunakan sebagai handle unik Anda.',
              style: TextStyle(color: SavaioTheme.onSurfaceVariant, fontSize: 11),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: SavaioTheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: SavaioTheme.primary,
                foregroundColor: SavaioTheme.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.onPrimaryFixed))
                  : Text('SIMPAN USERNAME', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
