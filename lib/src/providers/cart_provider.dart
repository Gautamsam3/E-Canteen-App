import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final _client = Supabase.instance.client;

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final response = await _client.from('carts').select().eq('user_id', userId);
    _items.clear();
    if (response is List) {
      for (final cartRow in response) {
        final menuItemRes =
            await _client
                .from('menu_items')
                .select()
                .eq('id', cartRow['menu_item_id'])
                .single();
        if (menuItemRes != null && menuItemRes is Map<String, dynamic>) {
          final menuItem = MenuItem.fromMap(menuItemRes);
          _items.add(
            CartItem(item: menuItem, quantity: cartRow['quantity'] as int),
          );
        }
      }
    }
    notifyListeners();
  }

  Future<void> addToCart(MenuItem item) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final index = _items.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (index >= 0) {
      _items[index].quantity++;
      await _client
          .from('carts')
          .update({'quantity': _items[index].quantity})
          .eq('user_id', userId)
          .eq('menu_item_id', item.id);
    } else {
      _items.add(CartItem(item: item));
      await _client.from('carts').insert({
        'user_id': userId,
        'menu_item_id': item.id,
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String itemId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    _items.removeWhere((cartItem) => cartItem.item.id == itemId);
    await _client
        .from('carts')
        .delete()
        .eq('user_id', userId)
        .eq('menu_item_id', itemId);
    notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final index = _items.indexWhere((cartItem) => cartItem.item.id == itemId);
    if (index >= 0 && quantity > 0) {
      _items[index].quantity = quantity;
      await _client
          .from('carts')
          .update({'quantity': quantity})
          .eq('user_id', userId)
          .eq('menu_item_id', itemId);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    _items.clear();
    await _client.from('carts').delete().eq('user_id', userId);
    notifyListeners();
  }
}
