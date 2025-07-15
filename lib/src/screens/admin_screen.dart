import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import '../services/menu_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'package:another_flushbar/flushbar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late MenuService _menuService;
  late OrderService _orderService;
  late TabController _tabController;
  List<OrderModel> _allOrders = [];
  bool _loadingOrders = false;
  String? _orderError;
  bool _isMenuPressed = false;
  bool _isOrderPressed = false;

  @override
  void initState() {
    super.initState();
    _menuService = MenuService();
    _orderService = OrderService();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadMenu();
      _loadAllOrders();
    });
  }

  Future<void> _loadAllOrders() async {
    setState(() {
      _loadingOrders = true;
      _orderError = null;
    });
    try {
      _allOrders = await _orderService.fetchAllOrders();
    } catch (e) {
      _orderError = e.toString();
    }
    setState(() {
      _loadingOrders = false;
    });
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    await _orderService.updateOrderStatus(orderId, status);
    await _loadAllOrders();
  }

  void _showMenuItemForm({MenuItem? item}) async {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(
      text: item?.price.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: item?.imageUrl ?? '',
    );
    final categoryController = TextEditingController(
      text: item?.category ?? '',
    );
    bool available = item?.available ?? true;
    final formKey = GlobalKey<FormState>();
    File? pickedImage;
    bool uploading = false;
    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEdit ? 'Edit Menu Item' : 'Add Menu Item'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Enter name'
                                        : null,
                          ),
                          TextFormField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                          ),
                          TextFormField(
                            controller: priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    v == null || double.tryParse(v) == null
                                        ? 'Enter valid price'
                                        : null,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: imageUrlController,
                                  decoration: const InputDecoration(
                                    labelText: 'Image URL',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.upload_file),
                                tooltip: 'Pick & Upload Image',
                                onPressed:
                                    uploading
                                        ? null
                                        : () async {
                                          final picker = ImagePicker();
                                          final picked = await picker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (picked != null) {
                                            setState(() => uploading = true);
                                            try {
                                              final url = await _menuService
                                                  .uploadImage(picked);
                                              imageUrlController.text = url;
                                            } catch (e) {
                                              if (context.mounted) {
                                                Flushbar(
                                                  message:
                                                      'Image upload failed: $e',
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  backgroundColor:
                                                      Colors.deepOrange,
                                                  flushbarPosition:
                                                      FlushbarPosition.TOP,
                                                  icon: const Icon(
                                                    Icons.error,
                                                    color: Colors.white,
                                                  ),
                                                  maxWidth: 320,
                                                  animationDuration:
                                                      const Duration(
                                                        milliseconds: 400,
                                                      ),
                                                  isDismissible: true,
                                                  forwardAnimationCurve:
                                                      Curves.easeOutBack,
                                                  reverseAnimationCurve:
                                                      Curves.easeInBack,
                                                  positionOffset: 24,
                                                ).show(context);
                                              }
                                            }
                                            setState(() => uploading = false);
                                          }
                                        },
                              ),
                            ],
                          ),
                          if (imageUrlController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SizedBox(
                                height: 80,
                                child: Image.network(
                                  imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          TextFormField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                          ),
                          SwitchListTile(
                            value: available,
                            onChanged: (val) => setState(() => available = val),
                            title: const Text('Available'),
                          ),
                          if (uploading)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: LinearProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          uploading
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
                                  Provider.of<MenuProvider>(
                                    context,
                                    listen: false,
                                  ).loadMenu();
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
    final isMenuLoading = menuProvider.isLoading;
    final items = menuProvider.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Menu'), Tab(text: 'Orders')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Menu Management
          isMenuLoading
              ? Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4,
                  itemBuilder:
                      (context, index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                ),
              )
              : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  double width = constraints.maxWidth;
                  if (width > 1400) {
                    crossAxisCount = 5;
                  } else if (width > 1100) {
                    crossAxisCount = 4;
                  } else if (width > 700) {
                    crossAxisCount = 3;
                  } else if (width > 500) {
                    crossAxisCount = 2;
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = menuProvider.items[index];
                            return StatefulBuilder(
                              builder: (context, setStateCard) {
                                bool cardPressed = false;
                                return GestureDetector(
                                  onTapDown:
                                      (_) => setStateCard(
                                        () => cardPressed = true,
                                      ),
                                  onTapUp:
                                      (_) => setStateCard(
                                        () => cardPressed = false,
                                      ),
                                  onTapCancel:
                                      () => setStateCard(
                                        () => cardPressed = false,
                                      ),
                                  child: AnimatedScale(
                                    scale: cardPressed ? 0.97 : 1.0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1.2,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(16),
                                                  ),
                                              child:
                                                  item.imageUrl.isNotEmpty
                                                      ? Image.network(
                                                        item.imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Container(
                                                              color: Colors
                                                                  .deepOrange
                                                                  .withOpacity(
                                                                    0.10,
                                                                  ),
                                                              child: const Icon(
                                                                Icons.fastfood,
                                                                size: 36,
                                                                color:
                                                                    Colors
                                                                        .deepOrange,
                                                              ),
                                                            ),
                                                      )
                                                      : Container(
                                                        color: Colors.deepOrange
                                                            .withOpacity(0.10),
                                                        child: const Icon(
                                                          Icons.fastfood,
                                                          size: 36,
                                                          color:
                                                              Colors.deepOrange,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .deepOrange
                                                              .withOpacity(
                                                                0.12,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          item.category,
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                color:
                                                                    Colors
                                                                        .deepOrange,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 11,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        '₹${item.price.toStringAsFixed(2)}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                              color:
                                                                  Colors
                                                                      .deepOrange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Flexible(
                                                    child: Text(
                                                      item.description,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          size: 18,
                                                        ),
                                                        onPressed:
                                                            () =>
                                                                _showMenuItemForm(
                                                                  item: item,
                                                                ),
                                                        tooltip: 'Edit',
                                                        splashRadius: 18,
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          size: 18,
                                                        ),
                                                        onPressed: () async {
                                                          await _menuService
                                                              .deleteMenuItem(
                                                                item.id,
                                                              );
                                                          if (mounted)
                                                            Provider.of<
                                                              MenuProvider
                                                            >(
                                                              context,
                                                              listen: false,
                                                            ).loadMenu();
                                                        },
                                                        tooltip: 'Delete',
                                                        splashRadius: 18,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }, childCount: menuProvider.items.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                mainAxisExtent: 250,
                              ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  );
                },
              ),
          // Order Management
          _loadingOrders
              ? Padding(
                padding: const EdgeInsets.all(12),
                child: ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder:
                      (context, index) => Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                ),
              )
              : _orderError != null
              ? Center(
                child: Text(
                  'Error: $_orderError',
                  style: TextStyle(color: Colors.red),
                ),
              )
              : _allOrders.isEmpty
              ? const Center(child: Text('No orders yet.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _allOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = _allOrders[index];
                  return StatefulBuilder(
                    builder: (context, setStateCard) {
                      bool cardPressed = false;
                      return GestureDetector(
                        onTapDown:
                            (_) => setStateCard(() => cardPressed = true),
                        onTapUp: (_) => setStateCard(() => cardPressed = false),
                        onTapCancel:
                            () => setStateCard(() => cardPressed = false),
                        child: AnimatedScale(
                          scale: cardPressed ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order.id.substring(0, 8)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${order.status}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.deepOrange),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total: ₹${order.items.fold(0.0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.deepOrange),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton.extended(
                onPressed: () => _showMenuItemForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              )
              : null,
    );
  }
}
