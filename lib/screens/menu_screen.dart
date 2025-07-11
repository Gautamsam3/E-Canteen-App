import 'package:flutter/material.dart';
import '../app_state.dart';

class MenuScreen extends StatelessWidget {
  final AppState appState;
  MenuScreen({super.key, required this.appState});

  final List<MenuItem> menuItems = [
    MenuItem(name: 'Burger', price: 50),
    MenuItem(name: 'Fries', price: 30),
    MenuItem(name: 'Pizza', price: 100),
    MenuItem(name: 'Samosa', price: 20),
    MenuItem(name: 'Coffee', price: 25),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('₹${item.price}'),
          trailing: ElevatedButton(
            onPressed: () {
              appState.addToCart(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} added to cart')),
              );
            },
            child: const Text('Add'),
          ),
        );
      },
    );
  }
}
