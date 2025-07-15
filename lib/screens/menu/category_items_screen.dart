import 'package:nomnom/models/category_model.dart';
import 'package:nomnom/models/menu_item_model.dart';
import 'package:nomnom/services/firestore_service.dart';
import 'package:nomnom/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class CategoryItemsScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryItemsScreen({super.key, required this.category});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  late Future<List<MenuItem>> _menuItemsFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _firestoreService.getMenuItems(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No items found in ${widget.category.name}.'));
          }

          final menuItems = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: menuItems.length,
            itemBuilder: (ctx, i) => FadeInUp(
              delay: Duration(milliseconds: 100 * i),
              child: MenuItemCard(item: menuItems[i]),
            ),
          );
        },
      ),
    );
  }
}
