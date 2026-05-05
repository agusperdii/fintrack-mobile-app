import 'package:flutter/material.dart';
import 'package:savaio/others.dart';

class AnalisaLoadingView extends StatelessWidget {
  const AnalisaLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: SavaioTheme.primary),
    );
  }
}

class AnalisaEmptyView extends StatelessWidget {
  const AnalisaEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Tidak ada data untuk bulan ini.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}

class AnalisaErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AnalisaErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: SavaioTheme.error, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data analisa',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _translateError(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: SavaioTheme.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  String _translateError(String error) {
    if (error.contains('PGRST202')) {
      return 'Fungsi database belum dipasang. Silakan jalankan skrip SQL di Supabase.';
    }
    return error;
  }
}
