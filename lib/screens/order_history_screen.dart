import 'package:flutter/material.dart';
import '../app_state.dart';

class OrderHistoryScreen extends StatelessWidget {
  final AppState appState;
  const OrderHistoryScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appState.orderHistory.length,
      itemBuilder: (context, index) {
        final order = appState.orderHistory[index];
        final total = order.fold(0, (sum, item) => sum + item.price);
        return ListTile(
          title: Text('Order #${index + 1}'),
          subtitle: Text('${order.length} items • Total ₹$total'),
        );
      },
    );
  }
}
