import 'package:nomnom/models/cart_item_model.dart';
import 'package:nomnom/models/menu_item_model.dart';
import 'package:nomnom/models/order_model.dart';
import 'package:nomnom/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items.update(
        menuItem.id,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        menuItem.id,
        () => CartItem(
            id: menuItem.id,
            name: menuItem.name,
            price: menuItem.price,
            quantity: 1,
            imageUrl: menuItem.imageUrl),
      );
    }
    notifyListeners();
  }

  void incrementCartItem(CartItem item) {
    _items.update(
      item.id,
      (existing) => CartItem(
        id: existing.id,
        name: existing.name,
        price: existing.price,
        quantity: existing.quantity + 1,
        imageUrl: existing.imageUrl,
      ),
    );
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  Future<void> placeOrder(String userId, String address) async {
    final order = OrderModel(
      id: DateTime.now().toIso8601String(),
      userId: userId,
      items: _items.values.toList(),
      totalAmount: totalAmount,
      address: address,
      timestamp: DateTime.now(),
    );

    await _firestoreService.placeOrder(order);
    clearCart();
  }
}
