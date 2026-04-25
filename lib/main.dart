import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/service_locator.dart';
import 'views/pages/main_screen.dart';
import 'views/pages/login_page.dart';
import 'controllers/auth_controller.dart';
import 'controllers/finance_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Service Locator
  sl.setup();
  // Pre-check auth
  await sl.authController.checkAuth();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl.authController),
        ChangeNotifierProvider.value(value: sl.financeController),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinTrack',
        theme: KineticVaultTheme.theme,
        home: Consumer<AuthController>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const MainScreen() : const LoginPage();
          },
        ),
      ),
    );
  }
}
