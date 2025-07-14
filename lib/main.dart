import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/config.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/menu_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/providers/order_provider.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Canteen App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return LoginScreen();
        } else {
          // Listen for order status changes
          final userId = session.user.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<OrderProvider>(context, listen: false).listenForOrderStatus(userId);
          });
          // Show notification if any
          final orderProvider = Provider.of<OrderProvider>(context);
          if (orderProvider.lastStatusChange != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(orderProvider.lastStatusChange!)),
              );
              orderProvider.clearStatusNotification();
            });
          }
          return HomeScreen();
        }
      },
    );
  }
}
