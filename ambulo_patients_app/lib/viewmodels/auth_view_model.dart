import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthMode { none, authenticated, guest }

class AuthViewModel extends ChangeNotifier {
  static const _kAuthToken = 'auth_token';
  static const _kAuthMode = 'auth_mode';

  AuthMode _mode = AuthMode.none;
  String? _token;

  AuthMode get mode => _mode;
  String? get token => _token;
  bool get isAuthed => _mode == AuthMode.authenticated && _token != null;
  bool get isGuest => _mode == AuthMode.guest;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAuthToken);
    final modeStr = prefs.getString(_kAuthMode);

    _token = token;
    _mode = switch (modeStr) {
      'guest' => AuthMode.guest,
      'authenticated' => (token == null ? AuthMode.none : AuthMode.authenticated),
      _ => AuthMode.none,
    };
    notifyListeners();
  }

  Future<void> signInWithOtpToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthToken, token);
    await prefs.setString(_kAuthMode, 'authenticated');
    _token = token;
    _mode = AuthMode.authenticated;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    await prefs.setString(_kAuthMode, 'guest');
    _token = null;
    _mode = AuthMode.guest;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    await prefs.remove(_kAuthMode);
    _token = null;
    _mode = AuthMode.none;
    notifyListeners();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) return null;

      // In a real backend flow, send `idToken` to your server.
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return null;

      await signInWithOtpToken(idToken);
      return account.email;
    } catch (_) {
      return null;
    }
  }
}

