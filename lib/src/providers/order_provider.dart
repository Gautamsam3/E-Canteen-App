import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> placeOrder(List<CartItem> cartItems) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _orderService.placeOrder(cartItems);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadOrderHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _orderService.fetchOrderHistory();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 