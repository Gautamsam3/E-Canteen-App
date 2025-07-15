import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/models/order_model.dart';
import 'package:nomnom/providers/auth_provider.dart';
import 'package:nomnom/providers/theme_provider.dart';
import 'package:nomnom/services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.userModel;

    // Correctly determines the theme state for the toggle switch
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: 12),
                      Text(user.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(user.email,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                // Settings Section
                ListTile(
                  leading: const Icon(Icons.nightlight_round),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
                const Divider(),
                // Order History Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Order History',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                // This now calls the method to build the real order list
                _buildOrderHistory(context, user.uid),
                const SizedBox(height: 20),
                // Logout Button
                ElevatedButton.icon(
                  onPressed: () => authProvider.signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError),
                ),
              ],
            ),
    );
  }

  // --- THIS IS THE NEW WIDGET THAT FETCHES AND DISPLAYS ORDERS ---
  Widget _buildOrderHistory(BuildContext context, String userId) {
    final firestoreService = FirestoreService();
    return FutureBuilder<List<OrderModel>>(
      future: firestoreService.getOrderHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not fetch order history.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("No orders yet!",
                    style: Theme.of(context).textTheme.titleMedium),
                const Text("Your past orders will appear here.",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final orders = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, // Important for nesting in a parent ListView
          physics:
              const NeverScrollableScrollPhysics(), // Disables scrolling for this list
          itemCount: orders.length,
          itemBuilder: (ctx, i) {
            final order = orders[i];
            // Uses the intl package to format the date nicely
            final formattedDate =
                DateFormat('dd MMM yyyy, hh:mm a').format(order.timestamp);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text('Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${order.items.length} items • Placed on $formattedDate'),
                trailing: Text('₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}
