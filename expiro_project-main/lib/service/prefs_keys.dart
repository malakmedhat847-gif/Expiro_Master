/// Central registry for all SharedPreferences keys.
///
/// ─── Global (app-level, shared across all users) ──────────────────────────
///   hasLaunched   – first-run onboarding flag
///   darkMode      – app-wide theme preference
///   isLoggedIn    – session gate used by SplashScreen
///   currentUserId – email of the user currently logged in
///
/// ─── User-scoped (prefixed with the logged-in user's ID) ──────────────────
///   All other keys are namespaced so each user has completely isolated storage.
class PrefsKeys {
  PrefsKeys._();

  // ── Global ──────────────────────────────────────────────────────────────────
  static const String hasLaunched   = 'has_launched';
  static const String darkMode      = 'dark_mode';
  static const String isLoggedIn    = 'is_logged_in';
  static const String currentUserId = 'current_user_id';

  // ── User-scoped helpers ────────────────────────────────────────────────────
  static String _u(String userId, String key) => 'u_${userId}_$key';

  static String profileName          (String userId) => _u(userId, 'profile_name');
  static String profileEmail         (String userId) => _u(userId, 'profile_email');
  static String items                (String userId) => _u(userId, 'items');
  static String idCounter            (String userId) => _u(userId, 'id_counter');
  static String notificationsEnabled (String userId) => _u(userId, 'notifications_enabled');
  static String notifyUnit           (String userId) => _u(userId, 'notify_unit');
  static String notifyValue          (String userId) => _u(userId, 'notify_value');
  static String authToken            (String userId) => _u(userId, 'auth_token');
}
