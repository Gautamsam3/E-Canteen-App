import '../models/menu_item.dart';
import '../utils/image_validator.dart';

class MenuService {
  // Menu data with real food images
  static List<MenuItem> _menuItems = [
    MenuItem(
      id: '1',
      name: 'Chicken Burger',
      description: 'Juicy grilled chicken with fresh vegetables',
      price: 299.00,
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&h=400&fit=crop',
      category: 'Burgers',
      rating: 4.5,
    ),
    MenuItem(
      id: '2',
      name: 'Margherita Pizza',
      description: 'Classic pizza with tomato sauce and mozzarella',
      price: 449.00,
      image: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&h=400&fit=crop',
      category: 'Pizza',
      rating: 4.2,
    ),
    MenuItem(
      id: '3',
      name: 'Caesar Salad',
      description: 'Fresh romaine lettuce with caesar dressing',
      price: 199.00,
      image: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500&h=400&fit=crop',
      category: 'Salads',
      rating: 4.0,
    ),
    MenuItem(
      id: '4',
      name: 'Chocolate Cake',
      description: 'Rich chocolate cake with cream frosting',
      price: 149.00,
      image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&h=400&fit=crop',
      category: 'Desserts',
      rating: 4.8,
    ),
    MenuItem(
      id: '5',
      name: 'Iced Coffee',
      description: 'Cold brew coffee with ice and milk',
      price: 99.00,
      image: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500&h=400&fit=crop',
      category: 'Beverages',
      rating: 4.3,
    ),
    MenuItem(
      id: '6',
      name: 'Butter Chicken',
      description: 'Creamy tomato-based curry with tender chicken',
      price: 329.00,
      image: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=500&h=400&fit=crop',
      category: 'Indian',
      rating: 4.7,
    ),
    MenuItem(
      id: '7',
      name: 'Biryani',
      description: 'Aromatic basmati rice with spiced chicken',
      price: 279.00,
      image: 'https://images.unsplash.com/photo-1563379091339-03246963d272?w=500&h=400&fit=crop',
      category: 'Indian',
      rating: 4.6,
    ),
    MenuItem(
      id: '8',
      name: 'Masala Dosa',
      description: 'Crispy crepe with spiced potato filling',
      price: 89.00,
      image: 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=500&h=400&fit=crop',
      category: 'Indian',
      rating: 4.4,
    ),
    MenuItem(
      id: '9',
      name: 'Fish & Chips',
      description: 'Beer-battered fish with crispy fries',
      price: 349.00,
      image: 'https://images.unsplash.com/photo-1544227099-6d9ac7f6b4b5?w=500&h=400&fit=crop',
      category: 'Western',
      rating: 4.3,
    ),
    MenuItem(
      id: '10',
      name: 'Pasta Carbonara',
      description: 'Creamy pasta with bacon and parmesan',
      price: 269.00,
      image: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=500&h=400&fit=crop',
      category: 'Western',
      rating: 4.5,
    ),
    MenuItem(
      id: '11',
      name: 'Veg Sandwich',
      description: 'Fresh vegetables with mayo and cheese',
      price: 79.00,
      image: 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=500&h=400&fit=crop',
      category: 'Snacks',
      rating: 4.1,
    ),
    MenuItem(
      id: '12',
      name: 'French Fries',
      description: 'Crispy golden fries with seasoning',
      price: 69.00,
      image: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&h=400&fit=crop',
      category: 'Snacks',
      rating: 4.2,
    ),
    MenuItem(
      id: '13',
      name: 'Mango Lassi',
      description: 'Refreshing yogurt drink with mango',
      price: 59.00,
      image: 'https://images.unsplash.com/photo-1553787244-6e6d0a5fea43?w=500&h=400&fit=crop',
      category: 'Beverages',
      rating: 4.4,
    ),
    MenuItem(
      id: '14',
      name: 'Gulab Jamun',
      description: 'Sweet milk dumplings in sugar syrup',
      price: 89.00,
      image: 'https://images.unsplash.com/photo-1571167439851-4dd9b7027c65?w=500&h=400&fit=crop',
      category: 'Desserts',
      rating: 4.6,
    ),
    MenuItem(
      id: '15',
      name: 'Samosa',
      description: 'Crispy pastry with spiced potato filling',
      price: 39.00,
      image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&h=400&fit=crop',
      category: 'Snacks',
      rating: 4.3,
    ),

  ];

  static Future<List<MenuItem>> getAllMenuItems() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    // Filter out items with invalid images
    return _menuItems.where((item) => ImageValidator.isValidImageUrl(item.image)).toList();
  }

  static Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    await Future.delayed(Duration(seconds: 1));
    return _menuItems
        .where((item) => 
            item.category == category && 
            ImageValidator.isValidImageUrl(item.image))
        .toList();
  }

  static Future<List<String>> getCategories() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _menuItems.map((item) => item.category).toSet().toList();
  }

  static Future<List<MenuItem>> searchMenuItems(String query) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _menuItems
        .where((item) =>
            ImageValidator.isValidImageUrl(item.image) &&
            (item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  static MenuItem? getMenuItemById(String id) {
    try {
      final item = _menuItems.firstWhere((item) => item.id == id);
      // Return item only if it has a valid image
      return ImageValidator.isValidImageUrl(item.image) ? item : null;
    } catch (e) {
      return null;
    }
  }

  /// Add a new method to validate and clean menu items
  static List<MenuItem> getValidMenuItems() {
    return _menuItems.where((item) => ImageValidator.isValidImageUrl(item.image)).toList();
  }

  /// Add a new method to get invalid menu items (for debugging/cleanup)
  static List<MenuItem> getInvalidMenuItems() {
    return _menuItems.where((item) => !ImageValidator.isValidImageUrl(item.image)).toList();
  }
}
