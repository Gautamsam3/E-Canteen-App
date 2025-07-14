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
      return const Center(child: CircularProgressIndicator());
    }
    if (orderProvider.error != null) {
      return Center(child: Text('Error: ${orderProvider.error}', style: TextStyle(color: Colors.red)));
    }
    final orders = orderProvider.orders;
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id.substring(0, 8)}', style: Theme.of(context).textTheme.titleMedium),
                    Chip(
                      label: Text(order.status),
                      backgroundColor: order.status == 'completed'
                          ? Colors.green[100]
                          : order.status == 'cancelled'
                              ? Colors.red[100]
                              : Colors.orange[100],
                      labelStyle: TextStyle(
                        color: order.status == 'completed'
                            ? Colors.green[800]
                            : order.status == 'cancelled'
                                ? Colors.red[800]
                                : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Placed on: ${order.createdAt.toLocal().toString().substring(0, 16)}'),
                const SizedBox(height: 8),
                ...order.items.map((item) => Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.imageUrl.isNotEmpty
                              ? Image.network(item.imageUrl, width: 36, height: 36, fit: BoxFit.cover)
                              : const Icon(Icons.fastfood, size: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.name)),
                        Text('x${item.quantity}'),
                        const SizedBox(width: 8),
                        Text('₹${item.price.toStringAsFixed(2)}'),
                      ],
                    )),
                const SizedBox(height: 8),
                Text('Total: ₹${order.items.fold(0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
} 