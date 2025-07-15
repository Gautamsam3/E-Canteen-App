import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/menu_service.dart';
import 'package:another_flushbar/flushbar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? selectedCategory;
  String sortBy = 'name';
  bool sortAsc = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> getCategories(List<MenuItem> items) {
    final categories = items.map((e) => e.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<MenuItem> getFilteredSortedItems(List<MenuItem> items) {
    var filtered =
        selectedCategory == null || selectedCategory == 'All'
            ? items
            : items.where((item) => item.category == selectedCategory).toList();

    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    item.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    filtered.sort((a, b) {
      int cmp;
      if (sortBy == 'price') {
        cmp = a.price.compareTo(b.price);
      } else {
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return sortAsc ? cmp : -cmp;
    });

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;

    if (menuProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (menuProvider.error != null) {
      return Center(
        child: Text(
          'Error: ${menuProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final items = menuProvider.items;
    final categories = ['All', ...getCategories(items)];
    final filteredItems = getFilteredSortedItems(items);

    int crossAxisCount = 1;
    double width = MediaQuery.of(context).size.width;
    if (width >= 1400) {
      crossAxisCount = 4;
    } else if (width >= 1100) {
      crossAxisCount = 3;
    } else if (width >= 800) {
      crossAxisCount = 2;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search food...',
              prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
              filled: true,
              fillColor: Colors.deepOrange.withOpacity(0.06),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => searchQuery = val),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final selected = cat == (selectedCategory ?? 'All');
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected:
                    (_) => setState(
                      () => selectedCategory = cat == 'All' ? null : cat,
                    ),
                selectedColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.deepOrange.withOpacity(0.1),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Menu",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: sortBy,
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                    ],
                    onChanged: (v) => setState(() => sortBy = v!),
                  ),
                  IconButton(
                    icon: Icon(
                      sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                    onPressed: () => setState(() => sortAsc = !sortAsc),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder:
                (context, index) => MenuItemCard(item: filteredItems[index]),
          ),
        ),
      ],
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    item.imageUrl.isNotEmpty
                        ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.deepOrange,
                                  size: 36,
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.deepOrange.withOpacity(0.10),
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.deepOrange,
                            size: 36,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.category,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                item.available
                    ? ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(item);
                        Flushbar(
                          message: '${item.name} added to cart!',
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor: Colors.deepOrange,
                          flushbarPosition: FlushbarPosition.TOP,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ).show(context);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                    : const Text(
                      'Out of stock',
                      style: TextStyle(color: Colors.red),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
