class OrderItemModel {
  final String id;
  final String menuItemId;
  final int quantity;
  final double price;
  final String name;
  final String imageUrl;

  OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    required this.name,
    required this.imageUrl,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      menuItemId: map['menu_item_id'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      name: map['name'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, List<OrderItemModel> items) {
    return OrderModel(
      id: map['id'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
    );
  }
} 