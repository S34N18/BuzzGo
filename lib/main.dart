import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_routes.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BuzzGoApp());
}

class BuzzGoApp extends StatelessWidget {
  const BuzzGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BuzzGo - Local Event Finder',
            theme: themeProvider.currentTheme,
            home: const SplashScreen(),
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}