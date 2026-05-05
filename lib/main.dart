import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://tnqssbtofbrewtlbipbf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRucXNzYnRvZmJyZXd0bGJpcGJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5NzMyNDcsImV4cCI6MjA5MzU0OTI0N30.piaYQzHW0w_W1dVsTagSZKFOFIP12q10oxoeEM10Os8',
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
        ChangeNotifierProvider.value(value: sl.financeController),
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
