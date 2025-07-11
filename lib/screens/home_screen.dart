import 'package:flutter/material.dart';
import '../app_state.dart';
import '../screens/menu_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/login_screen.dart';
import '../widgets/cart_badge.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      MenuScreen(appState: widget.appState),
      CartScreen(appState: widget.appState),
      OrderHistoryScreen(appState: widget.appState),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Canteen'),
        actions: [
          CartBadge(
            count: widget.appState.cart.length,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(appState: widget.appState),
                  ),
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
        ],
      ),
    );
  }
}
