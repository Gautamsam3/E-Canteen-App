import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isPressed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    if (orderProvider.isLoading) {
      // Loading skeleton
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.separated(
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder:
              (context, index) => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
        ),
      );
    }
    if (orderProvider.error != null) {
      return Center(
        child: Text(
          'Error: ${orderProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    final orders = orderProvider.orders;
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return StatefulBuilder(
          builder: (context, setStateCard) {
            bool cardPressed = false;
            return GestureDetector(
              onTapDown: (_) => setStateCard(() => cardPressed = true),
              onTapUp: (_) => setStateCard(() => cardPressed = false),
              onTapCancel: () => setStateCard(() => cardPressed = false),
              child: AnimatedScale(
                scale: cardPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                order.status,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor:
                                  order.status == 'completed'
                                      ? Colors.green[50]
                                      : order.status == 'cancelled'
                                      ? Colors.red[50]
                                      : Colors.orange[50],
                              labelStyle: TextStyle(
                                color:
                                    order.status == 'completed'
                                        ? Colors.green[800]
                                        : order.status == 'cancelled'
                                        ? Colors.red[800]
                                        : Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placed on: ${order.createdAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        if (order.addressLine1 != null &&
                            order.addressLine1!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Address:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                order.addressLine1 ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if ((order.addressLine2 ?? '').isNotEmpty)
                                Text(
                                  order.addressLine2 ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              Text(
                                '${order.city ?? ''}, ${order.state ?? ''} ${order.postalCode ?? ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                order.country ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ...order.items.map(
                          (item) => Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child:
                                    item.imageUrl.isNotEmpty
                                        ? Image.network(
                                          item.imageUrl,
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                        )
                                        : const Icon(
                                          Icons.fastfood,
                                          size: 18,
                                          color: Colors.deepOrange,
                                        ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '₹${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ₹${order.items.fold(0.0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
