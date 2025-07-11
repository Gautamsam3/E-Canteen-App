import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> get cartItems => CartService.cartItems;
  List<Order> get orderHistory => CartService.orderHistory;
  
  int get itemCount => CartService.itemCount;
  double get totalAmount => CartService.totalAmount;

  void addToCart(MenuItem menuItem, {int quantity = 1, String? specialInstructions}) {
    CartService.addToCart(menuItem, quantity: quantity, specialInstructions: specialInstructions);
    notifyListeners();
  }

  void removeFromCart(String menuItemId) {
    CartService.removeFromCart(menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int newQuantity) {
    CartService.updateQuantity(menuItemId, newQuantity);
    notifyListeners();
  }

  void clearCart() {
    CartService.clearCart();
    notifyListeners();
  }

  Future<String> placeOrder({
    String? deliveryAddress,
    String? paymentMethod,
  }) async {
    final orderId = await CartService.placeOrder(
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );
    notifyListeners();
    return orderId;
  }

  Order? getOrderById(String orderId) {
    return CartService.getOrderById(orderId);
  }
}
