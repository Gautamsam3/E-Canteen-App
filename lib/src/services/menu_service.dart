import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';

class MenuService {
  final _client = Supabase.instance.client;

  Future<List<MenuItem>> fetchMenuItems() async {
    final response = await _client.from('menu_items').select();
    if (response is List) {
      return response.map((item) => MenuItem.fromMap(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch menu items');
    }
  }
} 