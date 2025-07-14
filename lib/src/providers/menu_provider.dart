import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService = MenuService();
  List<MenuItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMenu() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _menuService.fetchMenuItems();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 