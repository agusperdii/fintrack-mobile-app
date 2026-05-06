import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  sl.setup();
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
        ChangeNotifierProvider.value(value: sl.transactionController),
        ChangeNotifierProvider.value(value: sl.notificationController),
        ChangeNotifierProvider.value(value: sl.dashboardController),
        ChangeNotifierProvider.value(value: sl.budgetController),
        ChangeNotifierProvider.value(value: sl.profileController),
        ChangeNotifierProvider.value(value: sl.analyticsController),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Savaio',
        theme: SavaioTheme.theme,
        home: Consumer<AuthController>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const MainLayout()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}
