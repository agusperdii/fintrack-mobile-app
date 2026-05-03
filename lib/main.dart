import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/layouts/main_layout.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
