import 'package:flutter/material.dart';
import 'theme/kinetic_vault_theme.dart';
import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Kinetic Vault',
      theme: KineticVaultTheme.theme,
      home: const MainScreen(),
    );
  }
}
