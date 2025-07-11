import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final int price;
  MenuItem({required this.name, required this.price});
}

class AppState extends ChangeNotifier {
  List<MenuItem> cart = [];
  List<List<MenuItem>> orderHistory = [];

  void addToCart(MenuItem item) {
    cart.add(item);
    notifyListeners();
  }

  void removeFromCart(MenuItem item) {
    cart.remove(item);
    notifyListeners();
  }

  void placeOrder() {
    if (cart.isNotEmpty) {
      orderHistory.add(List.from(cart));
      cart.clear();
      notifyListeners();
    }
  }
}
