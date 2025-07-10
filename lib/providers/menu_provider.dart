import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../utils/image_validator.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredItems = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  List<MenuItem> get menuItems => _filteredItems;
  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MenuProvider() {
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    _setLoading(true);
    _clearError();

    try {
      _menuItems = await MenuService.getAllMenuItems();
      _categories = await MenuService.getCategories();
      _applyFilter();
    } catch (e) {
      _setError('Failed to load menu items');
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
  }

  Future<void> searchMenuItems(String query) async {
    if (query.isEmpty) {
      _applyFilter();
      return;
    }

    _setLoading(true);
    try {
      final searchResults = await MenuService.searchMenuItems(query);
      _filteredItems = searchResults;
      notifyListeners();
    } catch (e) {
      _setError('Search failed');
    } finally {
      _setLoading(false);
    }
  }

  MenuItem? getMenuItemById(String id) {
    return MenuService.getMenuItemById(id);
  }

  void _applyFilter() {
    if (_selectedCategory == 'All') {
      _filteredItems = List.from(_menuItems);
    } else {
      _filteredItems = _menuItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Get count of menu items with invalid images (for debugging)
  int getInvalidImageCount() {
    return _menuItems.where((item) => !ImageValidator.isValidImageUrl(item.image)).length;
  }

  /// Get list of menu items with invalid images (for debugging)
  List<MenuItem> getItemsWithInvalidImages() {
    return _menuItems.where((item) => !ImageValidator.isValidImageUrl(item.image)).toList();
  }

  /// Force refresh and validate all menu items
  Future<void> refreshAndValidateMenuItems() async {
    _setLoading(true);
    _clearError();

    try {
      _menuItems = await MenuService.getAllMenuItems();
      
      // Log items with invalid images for debugging
      final invalidItems = getItemsWithInvalidImages();
      if (invalidItems.isNotEmpty) {
        debugPrint('Found ${invalidItems.length} menu items with invalid images:');
        for (final item in invalidItems) {
          debugPrint('- ${item.name}: ${item.image}');
        }
      }
      
      _categories = await MenuService.getCategories();
      _applyFilter();
    } catch (e) {
      _setError('Failed to refresh menu items: $e');
    } finally {
      _setLoading(false);
    }
  }
}
