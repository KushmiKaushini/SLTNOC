import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized, secure storage for login credentials.
///
/// Replaces the previous plaintext `SharedPreferences` storage of
/// `username`/`password` with platform-backed secure storage: Keychain on
/// iOS, EncryptedSharedPreferences/Keystore on Android.
///
/// `displayName` is not sensitive and intentionally stays in
/// `SharedPreferences` as before -- only the credentials move.
///
/// ## Migration
/// On first use after upgrading, any legacy plaintext credentials still
/// sitting in `SharedPreferences` are copied into secure storage and then
/// deleted from `SharedPreferences`. This means existing logged-in users are
/// **not** signed out by this change -- the migration happens transparently
/// the next time the app checks or reads credentials.
class CredentialStore {
  CredentialStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _kUsername = 'username';
  static const String _kPassword = 'password';

  static bool _migrationChecked = false;

  /// Copies any legacy plaintext credentials from SharedPreferences into
  /// secure storage, then removes them from SharedPreferences. Safe to call
  /// repeatedly -- only does real work once per process.
  static Future<void> _migrateLegacyIfNeeded() async {
    if (_migrationChecked) return;
    _migrationChecked = true;

    final prefs = await SharedPreferences.getInstance();
    final legacyUsername = prefs.getString(_kUsername);
    final legacyPassword = prefs.getString(_kPassword);

    if (legacyUsername == null && legacyPassword == null) {
      return; // Nothing to migrate.
    }

    // Only migrate into secure storage if it isn't already populated, so we
    // never clobber a newer credential with a stale plaintext one.
    final existingUsername = await _storage.read(key: _kUsername);
    if (existingUsername == null &&
        legacyUsername != null &&
        legacyPassword != null) {
      await _storage.write(key: _kUsername, value: legacyUsername);
      await _storage.write(key: _kPassword, value: legacyPassword);
    }

    // Always scrub the plaintext copies once we've had a chance to migrate.
    await prefs.remove(_kUsername);
    await prefs.remove(_kPassword);
  }

  /// Persists the given username/password to secure storage.
  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _migrateLegacyIfNeeded();
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kPassword, value: password);
  }

  static Future<String?> getUsername() async {
    await _migrateLegacyIfNeeded();
    return _storage.read(key: _kUsername);
  }

  static Future<String?> getPassword() async {
    await _migrateLegacyIfNeeded();
    return _storage.read(key: _kPassword);
  }

  /// Returns true only if both a username and a password are present.
  static Future<bool> hasCredentials() async {
    await _migrateLegacyIfNeeded();
    final username = await _storage.read(key: _kUsername);
    final password = await _storage.read(key: _kPassword);
    return username != null && password != null;
  }

  /// Clears stored credentials (used on logout).
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kPassword);
  }
}
