import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

class Address {
  final String id;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  Address({
    required this.id,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromMap(Map<String, dynamic> map) => Address(
    id: map['id'] as String,
    line1: map['address_line1'] as String? ?? '',
    line2: map['address_line2'] as String? ?? '',
    city: map['city'] as String? ?? '',
    state: map['state'] as String? ?? '',
    postalCode: map['postal_code'] as String? ?? '',
    country: map['country'] as String? ?? '',
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<Address> _addresses = [];
  bool _loadingAddresses = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAddresses();
  }

  Future<void> _loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profile = await ProfileService().fetchCurrentProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile.fullName;
        _avatarController.text = profile.avatarUrl;
      });
    }
  }

  Future<void> _loadAddresses() async {
    setState(() => _loadingAddresses = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final res = await Supabase.instance.client
        .from('addresses')
        .select()
        .eq('user_id', userId);
    if (res is List) {
      setState(() {
        _addresses = res.map((a) => Address.fromMap(a)).toList();
        _loadingAddresses = false;
      });
    } else {
      setState(() => _loadingAddresses = false);
    }
  }

  Future<void> _addOrEditAddress({Address? address}) async {
    final line1Controller = TextEditingController(text: address?.line1 ?? '');
    final line2Controller = TextEditingController(text: address?.line2 ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final stateController = TextEditingController(text: address?.state ?? '');
    final postalController = TextEditingController(
      text: address?.postalCode ?? '',
    );
    final countryController = TextEditingController(
      text: address?.country ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final isEdit = address != null;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEdit ? 'Edit Address' : 'Add Address'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: line1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 1',
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: line2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 2',
                      ),
                    ),
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    TextFormField(
                      controller: postalController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                      ),
                    ),
                    TextFormField(
                      controller: countryController,
                      decoration: const InputDecoration(labelText: 'Country'),
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
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId == null) return;
                  final data = {
                    'user_id': userId,
                    'address_line1': line1Controller.text,
                    'address_line2': line2Controller.text,
                    'city': cityController.text,
                    'state': stateController.text,
                    'postal_code': postalController.text,
                    'country': countryController.text,
                  };
                  if (isEdit) {
                    await Supabase.instance.client
                        .from('addresses')
                        .update(data)
                        .eq('id', address!.id);
                  } else {
                    await Supabase.instance.client
                        .from('addresses')
                        .insert(data);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    Flushbar(
                      message: isEdit ? 'Address updated!' : 'Address added!',
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: Colors.deepOrange,
                      flushbarPosition: FlushbarPosition.TOP,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      maxWidth: 320,
                      animationDuration: const Duration(milliseconds: 400),
                      isDismissible: true,
                      forwardAnimationCurve: Curves.easeOutBack,
                      reverseAnimationCurve: Curves.easeInBack,
                      positionOffset: 24,
                    ).show(context);
                  }
                  _loadAddresses();
                },
                child: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAddress(String id) async {
    await Supabase.instance.client.from('addresses').delete().eq('id', id);
    if (context.mounted) {
      Flushbar(
        message: 'Address deleted!',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.deepOrange,
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.delete, color: Colors.white),
        maxWidth: 320,
        animationDuration: const Duration(milliseconds: 400),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
        positionOffset: 24,
      ).show(context);
    }
    _loadAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await ProfileService().updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
      );
      await auth.login(auth.profile?.id ?? '', ''); // Refresh profile
      if (mounted) {
        Flushbar(
          message: 'Profile updated!',
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.deepOrange,
          flushbarPosition: FlushbarPosition.TOP,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          maxWidth: 320,
          animationDuration: const Duration(milliseconds: 400),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeInBack,
          positionOffset: 24,
        ).show(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          _avatarController.text.isNotEmpty &&
                                  !_avatarController.text.startsWith('data:')
                              ? NetworkImage(_avatarController.text)
                              : null,
                      child:
                          _avatarController.text.isEmpty ||
                                  _avatarController.text.startsWith('data:')
                              ? const Icon(Icons.person, size: 40)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _avatarController,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Addresses',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _addOrEditAddress(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    if (_loadingAddresses)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    if (!_loadingAddresses && _addresses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No addresses added.'),
                      ),
                    if (!_loadingAddresses && _addresses.isNotEmpty)
                      ..._addresses.map(
                        (address) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(address.line1),
                            subtitle: Text(
                              '${address.city}, ${address.state} ${address.postalCode}\n${address.country}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed:
                                      () => _addOrEditAddress(address: address),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteAddress(address.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
