import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/controllers/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  final prefs = await SharedPreferences.getInstance();
  sl.setup(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl.themeController),
        ChangeNotifierProvider.value(value: sl.authController),
        ChangeNotifierProvider.value(value: sl.transactionController),
        ChangeNotifierProvider.value(value: sl.notificationController),
        ChangeNotifierProvider.value(value: sl.dashboardController),
        ChangeNotifierProvider.value(value: sl.budgetController),
        ChangeNotifierProvider.value(value: sl.profileController),
        ChangeNotifierProvider.value(value: sl.analyticsController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Savaio',
            theme: SavaioTheme.lightTheme,
            darkTheme: SavaioTheme.theme,
            themeMode: theme.themeMode,
            home: Consumer<AuthController>(
              builder: (context, auth, _) {
                return auth.isAuthenticated
                    ? const MainLayout()
                    : const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
