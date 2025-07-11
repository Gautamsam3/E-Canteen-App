import 'package:flutter/material.dart';
import '../app_state.dart';

class CartScreen extends StatelessWidget {
  final AppState appState;
  const CartScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    int total = appState.cart.fold(0, (sum, item) => sum + item.price);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: appState.cart.length,
            itemBuilder: (context, index) {
              final item = appState.cart[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('₹${item.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () => appState.removeFromCart(item),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Total: ₹$total', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Checkout'),
                onPressed: () {
                  if (appState.cart.isNotEmpty) {
                    appState.placeOrder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
