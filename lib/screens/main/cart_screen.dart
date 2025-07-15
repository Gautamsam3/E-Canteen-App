import 'package:nomnom/providers/auth_provider.dart';
import 'package:nomnom/providers/cart_provider.dart';
import 'package:nomnom/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showCheckoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final addressController =
        TextEditingController(text: authProvider.userModel?.address);
    final phoneController =
        TextEditingController(text: authProvider.userModel?.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm Checkout',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                  labelText: 'Delivery Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Place Order'),
                onPressed: () async {
                  final address = addressController.text;
                  final phone = phoneController.text;
                  if (address.isNotEmpty && phone.isNotEmpty) {
                    // Update user address if it's different
                    if (address != authProvider.userModel?.address ||
                        phone != authProvider.userModel?.phone) {
                      await authProvider.updateUserAddress(address, phone);
                    }
                    // Place the order
                    await cartProvider.placeOrder(
                        authProvider.user!.uid, address);
                    Navigator.of(ctx).pop(); // Close bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Order placed successfully!')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text('Your Cart is Empty',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Add items from the menu to see them here.'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.toList()[i];
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * i),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(item.imageUrl,
                                  width: 60, height: 60, fit: BoxFit.cover),
                            ),
                            title: Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('₹${item.price.toStringAsFixed(2)}'),
                            trailing: QuantityStepper(
                              quantity: item.quantity,
                              onIncrement: () => cart.incrementCartItem(item),
                              onDecrement: () => cart.removeSingleItem(item.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCheckoutDialog(context),
                      child: const Text('Checkout'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
