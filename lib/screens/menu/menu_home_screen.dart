import 'package:nomnom/models/category_model.dart';
import 'package:nomnom/screens/menu/category_items_screen.dart';
import 'package:nomnom/services/firestore_service.dart';
import 'package:nomnom/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class MenuHomeScreen extends StatefulWidget {
  const MenuHomeScreen({super.key});

  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  late Future<List<CategoryModel>> _categoriesFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _firestoreService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          final categories = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (ctx, i) => FadeInUp(
              delay: Duration(milliseconds: 100 * i),
              child: CategoryTile(
                category: categories[i],
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CategoryItemsScreen(category: categories[i]),
                  ));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
