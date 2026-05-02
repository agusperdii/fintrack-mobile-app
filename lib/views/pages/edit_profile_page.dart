import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/organisms/app_header.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  const EditProfilePage({super.key, required this.currentName});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong');
      return;
    }
    setState(() { _isSaving = true; _errorMessage = null; });
    final success = await sl.financeController.updateProfile(fullName: name);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: SavaioTheme.tertiary),
        );
        Navigator.pop(context, true);
      } else {
        setState(() => _errorMessage = 'Gagal memperbarui profil. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: AppHeader(title: 'Edit Profil', showBackButton: true, showNotification: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text('Nama Lengkap', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: SavaioTheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: GoogleFonts.inter(color: SavaioTheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: SavaioTheme.surfaceContainerHigh,
                hintText: 'Masukkan nama lengkap Anda',
                hintStyle: TextStyle(color: SavaioTheme.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SavaioTheme.primary.withValues(alpha: 0.5)),
                ),
              ),
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
                  : Text('SIMPAN', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
