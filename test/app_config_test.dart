import 'package:flutter_test/flutter_test.dart';
import 'package:sltnoc/app_config.dart';

void main() {
  group('AppConfig Environment Loading Test', () {
    test('Reads configuration from environment / .env file', () {
      expect(AppConfig.environment, isNotEmpty);
      expect(AppConfig.apiBaseUrl, isNotEmpty);
      expect(AppConfig.soapEndpoint, isNotEmpty);
      expect(AppConfig.apiKey, isNotEmpty);
    });

    test('Validates development flags and defaults', () {
      expect(AppConfig.devUsername, isNotEmpty);
      expect(AppConfig.devPassword, isNotEmpty);
    });
  });
}
