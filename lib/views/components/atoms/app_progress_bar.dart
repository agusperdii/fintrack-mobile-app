// app_progress_bar.dart
// Widget atom progress bar linear sederhana untuk menampilkan persentase
// kemajuan (misalnya penggunaan anggaran).

import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  /// Nilai antara 0.0 hingga 1.0.
  final double value;
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? colorScheme.primary),
      ),
    );
  }
}
