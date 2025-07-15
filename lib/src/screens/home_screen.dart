import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'admin_screen.dart';
import '../providers/menu_provider.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
          child: ListTile(leading: Icon(Icons.person), title: Text('Account')),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ),
      ],
    );
    if (result == 'logout') {
      await auth.logout();
    } else if (result == 'profile') {
      if (context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      }
    }
    // Profile navigation can be implemented later
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;
    final menuProvider = Provider.of<MenuProvider>(context);
    final items = menuProvider.items;
    final screens = [
      const MenuScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      if (isAdmin) const AdminScreen(),
    ];
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No menu items available.',
              style: TextStyle(fontSize: 18),
            ),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Menu Item'),
                  onPressed: () => _showMenuItemForm(context),
                ),
              ),
          ],
        ),
      );
    }
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
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Orders',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  void _showMenuItemForm(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final categoryController = TextEditingController();
    bool available = true;
    final formKey = GlobalKey<FormState>();
    bool uploading = false;
    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Menu Item'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Enter name'
                                        : null,
                          ),
                          TextFormField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                          ),
                          TextFormField(
                            controller: priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    v == null || double.tryParse(v) == null
                                        ? 'Enter valid price'
                                        : null,
                          ),
                          TextFormField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                            ),
                          ),
                          TextFormField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                          ),
                          SwitchListTile(
                            value: available,
                            onChanged: (val) => setState(() => available = val),
                            title: const Text('Available'),
                          ),
                          if (uploading)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: LinearProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          uploading
                              ? null
                              : () async {
                                if (!formKey.currentState!.validate()) return;
                                final menuItem = MenuItem(
                                  id: '',
                                  name: nameController.text,
                                  description: descController.text,
                                  price: double.parse(priceController.text),
                                  imageUrl: imageUrlController.text,
                                  category: categoryController.text,
                                  available: available,
                                );
                                await MenuService().addMenuItem(menuItem);
                                if (context.mounted) {
                                  Provider.of<MenuProvider>(
                                    context,
                                    listen: false,
                                  ).loadMenu();
                                  Navigator.pop(context);
                                }
                              },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }
}
