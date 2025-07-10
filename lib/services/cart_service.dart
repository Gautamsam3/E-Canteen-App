import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class CartService {
  static List<CartItem> _cartItems = [];
  static List<Order> _orderHistory = [];

  static List<CartItem> get cartItems => _cartItems;
  static List<Order> get orderHistory => _orderHistory;

  static int get itemCount => _cartItems.length;

  static double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  static void addToCart(MenuItem menuItem, {int quantity = 1, String? specialInstructions}) {
    // Check if item already exists in cart
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingItemIndex != -1) {
      // Update quantity if item exists
      _cartItems[existingItemIndex].quantity += quantity;
    } else {
      // Add new item to cart
      _cartItems.add(CartItem(
        menuItem: menuItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      ));
    }
  }

  static void removeFromCart(String menuItemId) {
    _cartItems.removeWhere((item) => item.menuItem.id == menuItemId);
  }

  static void updateQuantity(String menuItemId, int newQuantity) {
    final itemIndex = _cartItems.indexWhere(
      (item) => item.menuItem.id == menuItemId,
    );

    if (itemIndex != -1) {
      if (newQuantity <= 0) {
        removeFromCart(menuItemId);
      } else {
        _cartItems[itemIndex].quantity = newQuantity;
      }
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }

  static Future<String> placeOrder({
    String? deliveryAddress,
    String? paymentMethod,
  }) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      id: orderId,
      items: List.from(_cartItems),
      totalAmount: totalAmount,
      status: OrderStatus.pending,
      orderTime: DateTime.now(),
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );

    _orderHistory.insert(0, order); // Add to beginning of list
    clearCart();

    return orderId;
  }

  static Order? getOrderById(String orderId) {
    try {
      return _orderHistory.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
}
