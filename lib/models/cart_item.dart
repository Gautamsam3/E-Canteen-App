import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  final String? specialInstructions;

  CartItem({
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
  });

  double get totalPrice => menuItem.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }
}
