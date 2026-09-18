import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ---------- REGISTER ----------
  static Future<void> register({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_name', name);
    await prefs.setString('pending_surname', surname);
    await prefs.setString('pending_email', email);

    if (_client.auth.currentUser != null) {
      await _client.auth.signOut();
    }
  }

  // ---------- ENSURE PROFILE EXISTS ----------
  static Future<void> ensureProfile() async {
    final user = currentUser;
    if (user == null || user.email == null) return;

    final existing = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (existing != null) return;

    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('pending_name') ?? '';
    final surname = prefs.getString('pending_surname') ?? '';

    await _client.from('profiles').insert({
      'id': user.id,
      'name': name,
      'surname': surname,
      'email': user.email,
    });

    await prefs.remove('pending_name');
    await prefs.remove('pending_surname');
    await prefs.remove('pending_email');
  }

  // ---------- LOGIN (email + password) ----------
  static Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ---------- LOGIN (magic link / OTP) ----------
  static Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'http://192.168.30.99:5100',
    );
  }

  static Future<void> verifyOtp(String email, String token) async {
    await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  // ---------- PASSWORD RESET ----------
  static Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'http://192.168.30.99:5100',
    );
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ---------- LOGOUT ----------
  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  // ---------- FETCH PROFILE ----------
  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }
}