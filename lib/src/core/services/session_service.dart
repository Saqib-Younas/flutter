import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight cache for the logged-in user's profile so screens don't have
/// to round-trip Supabase on every build. The DB / RLS remains the source
/// of truth for authorization — this is just a hint for the UI layer.
class SessionService {
  static SharedPreferences? _prefs;
  static String? _userId;
  static String? _userName;
  static String? _userEmail;
  static String? _userRole;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs?.getString('userId');
    _userName = _prefs?.getString('userName');
    _userEmail = _prefs?.getString('userEmail');
    _userRole = _prefs?.getString('userRole');
  }

  static String? get userId => _userId;
  static String? get userName => _userName;
  static String? get userEmail => _userEmail;
  static String? get userRole => _userRole;

  static bool get isLoggedIn => _userId != null;
  static bool get isAdmin => _userRole == 'admin';

  static Future<void> saveUserSession(
    String userId,
    String userName,
    String userEmail, {
    String role = 'user',
  }) async {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _userRole = role;

    await _prefs?.setString('userId', userId);
    await _prefs?.setString('userName', userName);
    await _prefs?.setString('userEmail', userEmail);
    await _prefs?.setString('userRole', role);
  }

  static Future<void> refreshUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('users')
        .select('name, email, role')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return;

    _userName = profile['name']?.toString() ?? user.userMetadata?['name'] ?? 'User';
    _userEmail = profile['email']?.toString() ?? user.email ?? '';
    _userRole = profile['role']?.toString() ?? 'user';

    await _prefs?.setString('userName', _userName!);
    await _prefs?.setString('userEmail', _userEmail!);
    await _prefs?.setString('userRole', _userRole!);
  }

  static Future<void> clearSession() async {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;

    await _prefs?.remove('userId');
    await _prefs?.remove('userName');
    await _prefs?.remove('userEmail');
    await _prefs?.remove('userRole');
  }
}
