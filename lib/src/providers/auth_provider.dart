import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  static String? pendingFullName;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String? _error;
  Profile? _profile;

  Profile? get profile => _profile;
  bool get isAdmin => _profile?.role == 'admin';

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    print('AuthProvider.login called with email=$email');
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      print('Calling signIn...');
      await _authService.signIn(email, password);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      print('Current userId after login: $userId');
      _profile = await _profileService.fetchCurrentProfile();
      print('Fetched profile after login: $_profile');
      if (_profile == null && userId != null) {
        print(
          'No profile found, attempting to insert profile for user $userId',
        );
        final insertResponse = await Supabase.instance.client
            .from('profiles')
            .insert({
              'id': userId,
              'full_name': pendingFullName ?? '',
              'role': 'USER',
              'avatar_url': '',
            });
        print('Profile insert response: $insertResponse');
        if (insertResponse == null ||
            (insertResponse is Map && insertResponse['error'] != null)) {
          _error =
              'Profile creation failed: ${insertResponse?['error'] ?? 'Unknown error'}';
          print('Profile creation error: $_error');
          notifyListeners();
        }
        _profile = await _profileService.fetchCurrentProfile();
        print('Fetched profile after insert: $_profile');
        pendingFullName = null;
      }
      notifyListeners();
      _isLoading = false;
      print('Login flow complete, returning true');
      return true;
    } catch (e) {
      _error = e.toString();
      print('Login error: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      print('Registering user: $email');
      final response = await _authService.signUp(email, password);
      // Do NOT insert profile here! Wait for login.
      pendingFullName = fullName;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Registration error: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _profile = null;
    notifyListeners();
  }
}
