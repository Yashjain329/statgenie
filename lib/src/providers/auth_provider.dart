import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  User? _current;
  bool _loading = false;

  User? get currentUser => _current;
  bool get isAuthenticated => _current != null;
  bool get isLoading => _loading;

  AuthProvider() {
    _client.auth.onAuthStateChange.listen((e) {
      _current = e.session?.user;
      notifyListeners();
    });
  }

  Future<void> checkAuthState() async {
    _current = _client.auth.currentUser;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      _current = res.user;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final res = await _client.auth.signUp(email: email, password: password);
      _current = res.user;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'com.example.statgenie://statgenie/login-callback');
  }

  Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(OAuthProvider.facebook, redirectTo: 'com.example.statgenie://statgenie/login-callback');
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: 'com.example.statgenie://statgenie/reset-password');
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _current = null;
    notifyListeners();
  }
}