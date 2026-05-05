import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/main_layout.dart';
import 'package:savaio/views/pages/auth/login_page.dart';
import 'package:savaio/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found, skipping dotenv load.");
  }

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
