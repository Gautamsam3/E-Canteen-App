import 'package:nomnom/models/user_model.dart';
import 'package:nomnom/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;

  AuthStatus _status = AuthStatus.Uninitialized;
  User? _user;
  UserModel? _userModel;

  AuthStatus get status => _status;
  User? get user => _user;
  UserModel? get userModel => _userModel;

  AuthProvider()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn(),
        _firestoreService = FirestoreService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.Unauthenticated;
      _userModel = null;
    } else {
      _user = firebaseUser;
      // Try to get the user's profile from Firestore
      _userModel = await _firestoreService.getUser(firebaseUser.uid);

      // If the user profile doesn't exist in Firestore,
      // create one ONLY if it's a social sign-in with a display name.
      // The manual email/password sign up process handles its own profile creation.
      if (_userModel == null &&
          firebaseUser.displayName != null &&
          firebaseUser.displayName!.isNotEmpty) {
        _userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName!,
          address: '',
          phone: '',
        );
        // Save this new user profile to the database
        await _firestoreService.addUser(_userModel!);
      }

      _status = AuthStatus.Authenticated;
    }
    notifyListeners();
  }



  Future<bool> signUp(String email, String password, String name) async {
    _status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = credential.user;

      _userModel = UserModel(
        uid: _user!.uid,
        email: email,
        name: name,
        address: '', // Initially empty
        phone: '',
      );

      await _firestoreService.addUser(_userModel!);
      _status = AuthStatus.Authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.Unauthenticated;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Create user in Firestore if they don't exist
      if (userCredential.additionalUserInfo!.isNewUser) {
        _userModel = UserModel(
            uid: _user!.uid,
            email: _user!.email!,
            name: _user!.displayName!,
            address: '',
            phone: '');
        await _firestoreService.addUser(_userModel!);
      }

      return true;
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _status = AuthStatus.Unauthenticated;
    _user = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle errors if necessary, e.g., user not found
      print("Error sending password reset email: $e");
    }
  }

  Future<void> updateUserAddress(String address, String phone) async {
    if (_userModel != null) {
      _userModel!.address = address;
      _userModel!.phone = phone;
      await _firestoreService.updateUser(_userModel!);
      notifyListeners();
    }
  }
}
