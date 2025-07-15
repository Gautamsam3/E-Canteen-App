import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../providers/order_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchAddresses(
    BuildContext context,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await Supabase.instance.client
        .from('addresses')
        .select()
        .eq('user_id', userId);
    if (res is List) return List<Map<String, dynamic>>.from(res);
    return [];
  }

  Future<Map<String, dynamic>?> _selectAddressDialog(
    BuildContext context,
  ) async {
    final addresses = await _fetchAddresses(context);
    if (addresses.isEmpty) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('No Address Found'),
              content: const Text(
                'Please add a delivery address in your profile.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return null;
    }
    Map<String, dynamic>? selected;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Delivery Address'),
            content: SizedBox(
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: addresses.length,
                itemBuilder: (context, i) {
                  final addr = addresses[i];
                  return RadioListTile<Map<String, dynamic>>(
                    value: addr,
                    groupValue: selected,
                    onChanged: (v) => selected = v,
                    title: Text(addr['address_line1'] ?? ''),
                    subtitle: Text(
                      '${addr['city'] ?? ''}, ${addr['state'] ?? ''} ${addr['postal_code'] ?? ''}\n${addr['country'] ?? ''}',
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Select'),
              ),
            ],
          ),
    );
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final items = cart.items;
    if (orderProvider.isLoading) {
      // Loading skeleton
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder:
              (context, index) => Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
        ),
      );
    }
    return Scaffold(
      body:
          items.isEmpty
              ? const Center(
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 20),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cartItem = items[index];
                        return CartItemTile(cartItem: cartItem);
                      },
                    ),
                  ),
                  if (orderProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  if (orderProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Error: ${orderProvider.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${cart.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              items.isEmpty || orderProvider.isLoading
                                  ? null
                                  : () async {
                                    final address = await _selectAddressDialog(
                                      context,
                                    );
                                    if (address == null) return;
                                    await orderProvider.placeOrder(
                                      items,
                                      address: address,
                                    );
                                    if (orderProvider.error == null) {
                                      cart.clearCart();
                                      Flushbar(
                                        message: 'Order placed successfully!',
                                        duration: const Duration(seconds: 2),
                                        margin: const EdgeInsets.all(16),
                                        borderRadius: BorderRadius.circular(12),
                                        backgroundColor: Colors.deepOrange,
                                        flushbarPosition: FlushbarPosition.TOP,
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        maxWidth: 320,
                                        animationDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        isDismissible: true,
                                        forwardAnimationCurve:
                                            Curves.easeOutBack,
                                        reverseAnimationCurve:
                                            Curves.easeInBack,
                                        positionOffset: 24,
                                      ).show(context);
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class CartItemTile extends StatefulWidget {
  final CartItem cartItem;
  const CartItemTile({super.key, required this.cartItem});
  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child:
                      widget.cartItem.item.imageUrl.isNotEmpty
                          ? Image.network(
                            widget.cartItem.item.imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          )
                          : const Icon(
                            Icons.fastfood,
                            size: 32,
                            color: Colors.deepOrange,
                          ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cartItem.item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '₹${widget.cartItem.item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setStateBtn) {
                        bool btnPressed = false;
                        return GestureDetector(
                          onTapDown:
                              (_) => setStateBtn(() => btnPressed = true),
                          onTapUp: (_) => setStateBtn(() => btnPressed = false),
                          onTapCancel:
                              () => setStateBtn(() => btnPressed = false),
                          child: AnimatedScale(
                            scale: btnPressed ? 0.9 : 1.0,
                            duration: const Duration(milliseconds: 80),
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                              onPressed:
                                  widget.cartItem.quantity > 1
                                      ? () => cart.updateQuantity(
                                        widget.cartItem.item.id,
                                        widget.cartItem.quantity - 1,
                                      )
                                      : null,
                              splashRadius: 18,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      '${widget.cartItem.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    StatefulBuilder(
                      builder: (context, setStateBtn) {
                        bool btnPressed = false;
                        return GestureDetector(
                          onTapDown:
                              (_) => setStateBtn(() => btnPressed = true),
                          onTapUp: (_) => setStateBtn(() => btnPressed = false),
                          onTapCancel:
                              () => setStateBtn(() => btnPressed = false),
                          child: AnimatedScale(
                            scale: btnPressed ? 0.9 : 1.0,
                            duration: const Duration(milliseconds: 80),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              onPressed:
                                  () => cart.updateQuantity(
                                    widget.cartItem.item.id,
                                    widget.cartItem.quantity + 1,
                                  ),
                              splashRadius: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    cart.removeFromCart(widget.cartItem.item.id);
                    Flushbar(
                      message: '${widget.cartItem.item.name} removed from cart',
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: Colors.deepOrange,
                      flushbarPosition: FlushbarPosition.TOP,
                      icon: const Icon(Icons.delete, color: Colors.white),
                      maxWidth: 320,
                      animationDuration: const Duration(milliseconds: 400),
                      isDismissible: true,
                      forwardAnimationCurve: Curves.easeOutBack,
                      reverseAnimationCurve: Curves.easeInBack,
                      positionOffset: 24,
                    ).show(context);
                  },
                  tooltip: 'Remove',
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
