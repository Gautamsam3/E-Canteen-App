import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom/models/category_model.dart';
import 'package:nomnom/models/menu_item_model.dart';
import 'package:nomnom/models/order_model.dart';
import 'package:nomnom/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Management
  Future<void> addUser(UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) {
    return _db.collection('users').doc(user.uid).update(user.toMap());
  }

  // Order Management
  Future<void> placeOrder(OrderModel order) {
    return _db.collection('orders').doc(order.id).set(order.toMap());
  }

  // --- THIS IS THE UPDATED METHOD ---
  // It now actually queries the database for orders.
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    final querySnapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    return querySnapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data()))
        .toList();
  }

  // --- MOCK DATA FUNCTIONS ---
  // In a real app, this data would come from your Firestore database.
  // For now, it's hardcoded to make the app runnable.

  Future<List<CategoryModel>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [
      CategoryModel(
          id: 'cat1',
          name: 'Burgers & Wraps',
          imageUrl:
              'https://images.unsplash.com/photo-1571091718767-18b5b1457add?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1172&q=80'),
      CategoryModel(
          id: 'cat2',
          name: 'Pizza & Pasta',
          imageUrl:
              'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'),
      CategoryModel(
          id: 'cat3',
          name: 'Snacks & Sides',
          imageUrl:
              'https://images.unsplash.com/photo-1599493356233-d73a7245?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80'),
      CategoryModel(
          id: 'cat4',
          name: 'Beverages',
          imageUrl:
              'https://images.unsplash.com/photo-1542871793-1c39a8070387?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'),
    ];
  }

  Future<List<MenuItem>> getMenuItems(String categoryId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // This is mock data. A real app would query Firestore:
    // _db.collection('menuItems').where('categoryId', isEqualTo: categoryId).get();

    final allItems = [
      MenuItem(
          id: 'm1',
          name: 'Classic Beef Burger',
          description:
              'Juicy beef patty with fresh lettuce, tomato, and our secret sauce.',
          price: 250,
          imageUrl:
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=699&q=80',
          categoryId: 'cat1'),
      MenuItem(
          id: 'm2',
          name: 'Spicy Chicken Wrap',
          description:
              'Grilled chicken strips with a spicy mayo and crisp veggies.',
          price: 220,
          imageUrl:
              'https://images.unsplash.com/photo-1607346256330-16803c5a61e8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
          categoryId: 'cat1'),
      MenuItem(
          id: 'm3',
          name: 'Margherita Pizza',
          description:
              'Classic pizza with fresh mozzarella, tomatoes, and basil.',
          price: 450,
          imageUrl:
              'https://images.unsplash.com/photo-1598021680135-63808ab4e411?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
          categoryId: 'cat2'),
      MenuItem(
          id: 'm4',
          name: 'Creamy Carbonara',
          description: 'Spaghetti in a rich and creamy egg and cheese sauce.',
          price: 380,
          imageUrl:
              'https://images.unsplash.com/photo-1608796395899-73d3257f369e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
          categoryId: 'cat2'),
      MenuItem(
          id: 'm5',
          name: 'Crispy French Fries',
          description: 'Golden, crispy, and lightly salted.',
          price: 120,
          imageUrl:
              'https://images.unsplash.com/photo-1541592106381-b5863c029476?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
          categoryId: 'cat3'),
      MenuItem(
          id: 'm6',
          name: 'Iced Latte',
          description: 'Chilled espresso with milk over ice.',
          price: 150,
          imageUrl:
              'https://images.unsplash.com/photo-1517701550927-4e4f36743e52?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80',
          categoryId: 'cat4'),
    ];

    return allItems.where((item) => item.categoryId == categoryId).toList();
  }
}
