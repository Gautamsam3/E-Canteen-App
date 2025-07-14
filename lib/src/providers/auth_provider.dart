import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  Profile? _profile;

  Profile? get profile => _profile;
  bool get isAdmin => _profile?.role == 'admin';

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
      _profile = await _profileService.fetchCurrentProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signUp(email, password);
      _profile = await _profileService.fetchCurrentProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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