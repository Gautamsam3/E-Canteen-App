import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as models;
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  models.User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  models.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session?.user != null) {
        _user = AuthService.currentUser;
      } else {
        _user = null;
      }
      notifyListeners();
    });
    
    // Get initial session
    _user = AuthService.currentUser;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await AuthService.login(email, password);
      if (success) {
        _user = AuthService.currentUser;
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      _setError(AuthService.getAuthErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await AuthService.register(name, email, password, phone);
      if (success) {
        _user = AuthService.currentUser;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed. Please check your details.');
        return false;
      }
    } catch (e) {
      _setError(AuthService.getAuthErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await AuthService.logout();
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await AuthService.resetPassword(email);
      if (!success) {
        _setError('Failed to send reset email');
      }
      return success;
    } catch (e) {
      _setError(AuthService.getAuthErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
