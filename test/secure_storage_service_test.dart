import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sltnoc/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService Tests', () {
    late SecureStorageService service;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      service = SecureStorageService();
    });

    test('saveCredentials stores username, password, and displayName', () async {
      await service.saveCredentials(
        username: 'SLT12345',
        password: 'securePassword!',
        displayName: 'John Doe',
      );

      expect(await service.getUsername(), 'SLT12345');
      expect(await service.getPassword(), 'securePassword!');
      expect(await service.getDisplayName(), 'John Doe');
      expect(await service.hasValidCredentials(), isTrue);
    });

    test('clearCredentials purges username, password, and displayName', () async {
      await service.saveCredentials(
        username: 'SLT12345',
        password: 'securePassword!',
        displayName: 'John Doe',
      );

      await service.clearCredentials();

      expect(await service.getUsername(), isNull);
      expect(await service.getPassword(), isNull);
      expect(await service.getDisplayName(), isNull);
      expect(await service.hasValidCredentials(), isFalse);
    });

    test('server url and useLocalServer get/set methods operate correctly', () async {
      await service.setServerUrl('https://noc.slt.lk');
      expect(await service.getServerUrl(), 'https://noc.slt.lk');

      await service.setUseLocalServer(false);
      expect(await service.getUseLocalServer(), isFalse);

      await service.setUseLocalServer(true);
      expect(await service.getUseLocalServer(), isTrue);
    });

    test('migrateFromSharedPreferences migrates legacy credentials and purges them', () async {
      SharedPreferences.setMockInitialValues({
        'username': 'legacyUser',
        'password': 'legacyPassword',
        'displayName': 'Legacy User',
        'serverUrl': 'http://192.168.1.10:3000',
        'useLocalServer': false,
      });

      // Secure storage starts empty
      expect(await service.getUsername(), isNull);

      // Perform migration
      await service.migrateFromSharedPreferences();

      // Verify migrated data in secure storage
      expect(await service.getUsername(), 'legacyUser');
      expect(await service.getPassword(), 'legacyPassword');
      expect(await service.getDisplayName(), 'Legacy User');
      expect(await service.getServerUrl(), 'http://192.168.1.10:3000');
      expect(await service.getUseLocalServer(), isFalse);

      // Verify plaintext keys removed from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('username'), isFalse);
      expect(prefs.containsKey('password'), isFalse);
      expect(prefs.containsKey('displayName'), isFalse);
      expect(prefs.containsKey('serverUrl'), isFalse);
      expect(prefs.containsKey('useLocalServer'), isFalse);
    });
  });
}
