import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/service_locator.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/pages/onboarding/welcome_page.dart';

void main() {
  // Initialize Service Locator for scalable backend approach
  sl.setup();
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
      home: const WelcomePage(),
      routes: {
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
