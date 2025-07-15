import 'package:nomnom/providers/auth_provider.dart';
import 'package:nomnom/providers/cart_provider.dart';
import 'package:nomnom/providers/theme_provider.dart';
import 'package:nomnom/screens/auth/login_screen.dart';
import 'package:nomnom/screens/main/home_screen.dart';
import 'package:nomnom/screens/splash_screen.dart';
import 'package:nomnom/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'NomNom',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.Uninitialized:
            return const SplashScreen();
          case AuthStatus.Authenticated:
            return const HomeScreen();
          case AuthStatus.Unauthenticated:
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
