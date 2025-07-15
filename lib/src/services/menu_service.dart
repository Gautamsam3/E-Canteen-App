import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class MenuService {
  final _client = Supabase.instance.client;

  Future<List<MenuItem>> fetchMenuItems() async {
    final response = await _client.from('menu_items').select();
    if (response is List) {
      return response
          .map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch menu items');
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _client.from('menu_items').insert({
      'name': item.name,
      'description': item.description,
      'price': item.price,
      'image_url': item.imageUrl,
      'category': item.category,
      'available': item.available,
    });
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _client
        .from('menu_items')
        .update({
          'name': item.name,
          'description': item.description,
          'price': item.price,
          'image_url': item.imageUrl,
          'category': item.category,
          'available': item.available,
        })
        .eq('id', item.id);
  }

  Future<void> deleteMenuItem(String id) async {
    await _client.from('menu_items').delete().eq('id', id);
  }

  Future<String> uploadImage(XFile file) async {
    final fileName =
        DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.name;
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await _client.storage.from('menu-images').uploadBinary(fileName, bytes);
    } else {
      await _client.storage
          .from('menu-images')
          .upload(fileName, File(file.path));
    }
    final url = _client.storage.from('menu-images').getPublicUrl(fileName);
    return url;
  }
}
