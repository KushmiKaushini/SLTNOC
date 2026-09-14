import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  // Storage key constants
  static const String keyUsername = 'username';
  static const String keyPassword = 'password';
  static const String keyDisplayName = 'displayName';
  static const String keyServerUrl = 'serverUrl';
  static const String keyUseLocalServer = 'useLocalServer';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ---------------------------------------------------------------------------
  // Core Storage Operations
  // ---------------------------------------------------------------------------

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // ---------------------------------------------------------------------------
  // Credential Management Helpers
  // ---------------------------------------------------------------------------

  /// Saves the user's login credentials securely in encrypted storage.
  Future<void> saveCredentials({
    required String username,
    required String password,
    String? displayName,
  }) async {
    await _storage.write(key: keyUsername, value: username.trim());
    await _storage.write(key: keyPassword, value: password);
    if (displayName != null && displayName.isNotEmpty) {
      await _storage.write(key: keyDisplayName, value: displayName.trim());
    }
  }

  /// Retrieves the stored username (SLT service number).
  Future<String?> getUsername() async {
    return await _storage.read(key: keyUsername);
  }

  /// Retrieves the stored password.
  Future<String?> getPassword() async {
    return await _storage.read(key: keyPassword);
  }

  /// Retrieves the stored display name.
  Future<String?> getDisplayName() async {
    return await _storage.read(key: keyDisplayName);
  }

  /// Checks if both username and password exist in secure storage.
  Future<bool> hasValidCredentials() async {
    final username = await getUsername();
    final password = await getPassword();
    return username != null &&
        username.isNotEmpty &&
        password != null &&
        password.isNotEmpty;
  }

  /// Clears only user authentication credentials on logout.
  Future<void> clearCredentials() async {
    await _storage.delete(key: keyUsername);
    await _storage.delete(key: keyPassword);
    await _storage.delete(key: keyDisplayName);
  }

  // ---------------------------------------------------------------------------
  // Server Configuration Helpers
  // ---------------------------------------------------------------------------

  Future<String?> getServerUrl() async {
    return await _storage.read(key: keyServerUrl);
  }

  Future<void> setServerUrl(String url) async {
    await _storage.write(key: keyServerUrl, value: url.trim());
  }

  Future<bool> getUseLocalServer({bool defaultValue = true}) async {
    final val = await _storage.read(key: keyUseLocalServer);
    if (val == null) return defaultValue;
    return val == 'true';
  }

  Future<void> setUseLocalServer(bool useLocal) async {
    await _storage.write(key: keyUseLocalServer, value: useLocal.toString());
  }

  // ---------------------------------------------------------------------------
  // Automatic Migration from SharedPreferences (Plaintext -> Encrypted)
  // ---------------------------------------------------------------------------

  /// Scans SharedPreferences for legacy plaintext credentials and configuration,
  /// securely imports them into FlutterSecureStorage, and purges the plaintext keys.
  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for legacy credentials
      final legacyUsername = prefs.getString(keyUsername);
      final legacyPassword = prefs.getString(keyPassword);
      final legacyDisplayName = prefs.getString(keyDisplayName);

      bool migratedCredentials = false;

      if (legacyUsername != null && legacyUsername.isNotEmpty) {
        if ((await getUsername()) == null) {
          await _storage.write(key: keyUsername, value: legacyUsername);
        }
        await prefs.remove(keyUsername);
        migratedCredentials = true;
      }

      if (legacyPassword != null && legacyPassword.isNotEmpty) {
        if ((await getPassword()) == null) {
          await _storage.write(key: keyPassword, value: legacyPassword);
        }
        await prefs.remove(keyPassword);
        migratedCredentials = true;
      }

      if (legacyDisplayName != null && legacyDisplayName.isNotEmpty) {
        if ((await getDisplayName()) == null) {
          await _storage.write(key: keyDisplayName, value: legacyDisplayName);
        }
        await prefs.remove(keyDisplayName);
        migratedCredentials = true;
      }

      // Check for legacy server settings
      final legacyServerUrl = prefs.getString(keyServerUrl);
      if (legacyServerUrl != null && legacyServerUrl.isNotEmpty) {
        if ((await getServerUrl()) == null) {
          await _storage.write(key: keyServerUrl, value: legacyServerUrl);
        }
        await prefs.remove(keyServerUrl);
      }

      final legacyUseLocalServer = prefs.getBool(keyUseLocalServer);
      if (legacyUseLocalServer != null) {
        if ((await _storage.read(key: keyUseLocalServer)) == null) {
          await _storage.write(
              key: keyUseLocalServer, value: legacyUseLocalServer.toString());
        }
        await prefs.remove(keyUseLocalServer);
      }

      if (kDebugMode && migratedCredentials) {
        debugPrint(
            'SecureStorageService: Successfully migrated legacy credentials to encrypted secure storage.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'SecureStorageService: Error during SharedPreferences migration: $e');
      }
    }
  }
}