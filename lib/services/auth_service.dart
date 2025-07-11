import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as models;

class AuthService {
  static final _supabase = Supabase.instance.client;
  
  static models.User? get currentUser {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser != null) {
      return models.User(
        id: supabaseUser.id,
        name: supabaseUser.userMetadata?['name'] ?? 'User',
        email: supabaseUser.email ?? '',
        phone: supabaseUser.phone ?? '',
        profileImage: supabaseUser.userMetadata?['profile_image'],
      );
    }
    return null;
  }
  
  static bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Register new user
  static Future<bool> register(String name, String email, String password, String phone) async {
    try {
      print('Attempting registration with email: $email');
      
      final trimmedEmail = email.trim().toLowerCase();
      final trimmedPassword = password.trim();
      final trimmedName = name.trim();
      final trimmedPhone = phone.trim();
      
      // First, try to sign up the user
      final response = await _supabase.auth.signUp(
        email: trimmedEmail,
        password: trimmedPassword,
        data: {
          'name': trimmedName,
          'phone': trimmedPhone,
        },
        emailRedirectTo: null, // Disable email redirect for now
      );

      if (response.user != null) {
        // Wait a bit for the user to be fully created
        await Future.delayed(const Duration(milliseconds: 500));
        
        // If email confirmation is disabled, the user should be logged in automatically
        // If not, we still consider registration successful
        print('User registered successfully: ${response.user!.id}');
        
        try {
          // Try to create user profile in database
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'name': trimmedName,
            'email': trimmedEmail,
            'phone': trimmedPhone,
            'created_at': DateTime.now().toIso8601String(),
          });
          print('Profile created successfully');
        } catch (profileError) {
          print('Profile creation error: $profileError');
          // If profile creation fails, we still consider registration successful
          // The user can login and we can create the profile later
        }
        
        return true;
      } else if (response.session != null) {
        // User was created and logged in automatically
        return true;
      }
      
      return false;
    } catch (e) {
      print('Registration error: $e');
      
      // Check if it's a rate limit error
      if (e.toString().contains('over_email_send_rate_limit')) {
        // Wait and retry once
        await Future.delayed(const Duration(seconds: 3));
        try {
          final retryResponse = await _supabase.auth.signUp(
            email: email,
            password: password,
            data: {
              'name': name,
              'phone': phone,
            },
          );
          return retryResponse.user != null;
        } catch (retryError) {
          print('Retry registration error: $retryError');
          return false;
        }
      }
      
      return false;
    }
  }

  // Login with email and password
  static Future<bool> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');
      
      // Trim whitespace and convert email to lowercase
      final trimmedEmail = email.trim().toLowerCase();
      final trimmedPassword = password.trim();
      
      final response = await _supabase.auth.signInWithPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      
      print('Login response: ${response.user?.id}');
      return response.user != null;
    } catch (e) {
      print('Login error details: $e');
      print('Error type: ${e.runtimeType}');
      rethrow; // Re-throw to let AuthProvider handle the error message
    }
  }

  // Logout
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Reset password
  static Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  // Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      // This is a workaround since Supabase doesn't have a direct way to check email existence
      await _supabase.auth.signInWithPassword(
        email: email,
        password: 'dummy_password_to_check_email',
      );
      return false; // If no error, email doesn't exist
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        return true; // Email exists but password is wrong
      }
      return false; // Email doesn't exist
    }
  }

  // Get error message from Supabase error
  static String getAuthErrorMessage(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    print('Processing error message: $errorMessage');
    
    if (errorMessage.contains('over_email_send_rate_limit')) {
      return 'Too many requests. Please wait a moment before trying again.';
    } else if (errorMessage.contains('invalid login credentials') || 
               errorMessage.contains('invalid_grant')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (errorMessage.contains('email not confirmed')) {
      return 'Please check your email and confirm your account before logging in.';
    } else if (errorMessage.contains('user not found')) {
      return 'No account found with this email. Please register first.';
    } else if (errorMessage.contains('user already registered')) {
      return 'An account with this email already exists. Please login instead.';
    } else if (errorMessage.contains('password should be at least')) {
      return 'Password should be at least 6 characters';
    } else if (errorMessage.contains('invalid email')) {
      return 'Please enter a valid email address';
    } else if (errorMessage.contains('signup is disabled')) {
      return 'New registrations are currently disabled';
    } else if (errorMessage.contains('too_many_requests') || 
               errorMessage.contains('rate limit')) {
      return 'Too many attempts. Please wait before trying again.';
    } else if (errorMessage.contains('network') || 
               errorMessage.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('404')) {
      return 'Service not available. Please contact support.';
    }
    
    return 'Authentication failed. Please try again or contact support.';
  }
}
