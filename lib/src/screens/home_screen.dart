import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // TODO: Replace with real role check from user profile
  bool get isAdmin => false;

  List<Widget> get _screens => [
        const MenuScreen(),
        const CartScreen(),
        const OrderHistoryScreen(),
        if (isAdmin) const AdminScreen(),
      ];

  List<BottomNavigationBarItem> get _navItems => [
        const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
        if (isAdmin)
          const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showUserMenu(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ),
      ],
    );
    if (result == 'logout') {
      await auth.logout();
    }
    // Profile navigation can be implemented later
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Canteen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showUserMenu(context),
            tooltip: 'User Menu',
          ),
        ],
      ),
      body: [
        const MenuScreen(),
        const CartScreen(),
        const OrderHistoryScreen(),
        if (isAdmin) const AdminScreen(),
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          const NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          const NavigationDestination(icon: Icon(Icons.history), label: 'Orders'),
          if (isAdmin)
            const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
} 