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
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  OrderModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.items,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory OrderModel.fromMap(
    Map<String, dynamic> map,
    List<OrderItemModel> items,
  ) {
    return OrderModel(
      id: map['id'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
      addressLine1: map['address_line1'] as String?,
      addressLine2: map['address_line2'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      postalCode: map['postal_code'] as String?,
      country: map['country'] as String?,
    );
  }
}
