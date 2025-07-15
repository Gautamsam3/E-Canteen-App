import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/models/cart_item_model.dart'; // Make sure this path is correct for your project

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String address;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'address': address,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // --- ADD THIS CONSTRUCTOR ---
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['userId'],
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      address: map['address'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}