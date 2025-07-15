import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onDecrement),
        Text(quantity.toString(), style: Theme.of(context).textTheme.titleMedium),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onIncrement),
      ],
    );
  }
}