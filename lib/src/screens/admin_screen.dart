import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import '../services/menu_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late MenuService _menuService;

  @override
  void initState() {
    super.initState();
    _menuService = MenuService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadMenu();
    });
  }

  void _showMenuItemForm({MenuItem? item}) async {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    final categoryController = TextEditingController(text: item?.category ?? '');
    bool available = item?.available ?? true;
    final formKey = GlobalKey<FormState>();
    File? pickedImage;
    bool uploading = false;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Menu Item' : 'Add Menu Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(labelText: 'Image URL'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload_file),
                        tooltip: 'Pick & Upload Image',
                        onPressed: uploading
                            ? null
                            : () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(source: ImageSource.gallery);
                                if (picked != null) {
                                  setState(() => uploading = true);
                                  try {
                                    final url = await _menuService.uploadImage(File(picked.path));
                                    imageUrlController.text = url;
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Image upload failed: $e')),
                                      );
                                    }
                                  }
                                  setState(() => uploading = false);
                                }
                              },
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  SwitchListTile(
                    value: available,
                    onChanged: (val) => setState(() => available = val),
                    title: const Text('Available'),
                  ),
                  if (uploading) const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: uploading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final menuItem = MenuItem(
                        id: item?.id ?? '',
                        name: nameController.text,
                        description: descController.text,
                        price: double.parse(priceController.text),
                        imageUrl: imageUrlController.text,
                        category: categoryController.text,
                        available: available,
                      );
                      if (isEdit) {
                        await _menuService.updateMenuItem(menuItem);
                      } else {
                        await _menuService.addMenuItem(menuItem);
                      }
                      if (mounted) {
                        Provider.of<MenuProvider>(context, listen: false).loadMenu();
                        Navigator.pop(context);
                      }
                    },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final items = menuProvider.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Menu Management')),
      body: items.isEmpty
          ? const Center(child: Text('No menu items.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: item.imageUrl.isNotEmpty
                        ? Image.network(item.imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood, size: 32),
                    title: Text(item.name),
                    subtitle: Text('₹${item.price.toStringAsFixed(2)} | ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showMenuItemForm(item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _menuService.deleteMenuItem(item.id);
                            if (mounted) Provider.of<MenuProvider>(context, listen: false).loadMenu();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMenuItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
} 