import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final _client = Supabase.instance.client;

  Future<void> placeOrder(List<CartItem> cartItems) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    final orderRes = await _client.from('orders').insert({
      'user_id': userId,
      'status': 'pending',
    }).select().single();
    final orderId = orderRes['id'] as String;
    final orderItems = cartItems.map((cartItem) => {
      'order_id': orderId,
      'menu_item_id': cartItem.item.id,
      'quantity': cartItem.quantity,
      'price': cartItem.item.price,
    }).toList();
    await _client.from('order_items').insert(orderItems);
  }

  Future<List<OrderModel>> fetchOrderHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    final orders = await _client.from('orders').select().eq('user_id', userId).order('created_at', ascending: false);
    List<OrderModel> result = [];
    for (final order in orders) {
      final orderItems = await _client.from('order_items').select('*,menu_items(name,image_url)').eq('order_id', order['id']);
      final items = orderItems.map<OrderItemModel>((item) => OrderItemModel(
        id: item['id'] as String,
        menuItemId: item['menu_item_id'] as String,
        quantity: item['quantity'] as int,
        price: (item['price'] as num).toDouble(),
        name: item['menu_items']['name'] as String? ?? '',
        imageUrl: item['menu_items']['image_url'] as String? ?? '',
      )).toList();
      result.add(OrderModel.fromMap(order, items));
    }
    return result;
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    final orders = await _client.from('orders').select().order('created_at', ascending: false);
    List<OrderModel> result = [];
    for (final order in orders) {
      final orderItems = await _client.from('order_items').select('*,menu_items(name,image_url)').eq('order_id', order['id']);
      final items = orderItems.map<OrderItemModel>((item) => OrderItemModel(
        id: item['id'] as String,
        menuItemId: item['menu_item_id'] as String,
        quantity: item['quantity'] as int,
        price: (item['price'] as num).toDouble(),
        name: item['menu_items']['name'] as String? ?? '',
        imageUrl: item['menu_items']['image_url'] as String? ?? '',
      )).toList();
      result.add(OrderModel.fromMap(order, items));
    }
    return result;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);
  }
} 