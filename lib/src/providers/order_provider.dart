import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _orderStatusSub;
  String? _lastStatusChange;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastStatusChange => _lastStatusChange;

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

  void listenForOrderStatus(String userId) {
    _orderStatusSub?.cancel();
    _orderStatusSub = Supabase.instance.client
        .from('orders:user_id=eq.$userId')
        .on(SupabaseEventTypes.update, (payload) {
      final newStatus = payload.newRecord['status'] as String?;
      final orderId = payload.newRecord['id'] as String?;
      if (newStatus != null && orderId != null) {
        _lastStatusChange = 'Order #${orderId.substring(0, 8)} status updated: $newStatus';
        notifyListeners();
      }
    }).subscribe();
  }

  void clearStatusNotification() {
    _lastStatusChange = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _orderStatusSub?.cancel();
    super.dispose();
  }
} 