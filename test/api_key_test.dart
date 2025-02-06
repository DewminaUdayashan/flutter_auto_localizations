import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';

String? getApiKey({Map<String, String>? mockEnv}) {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  return env['GOOGLE_TRANSLATE_API_KEY'] ??
      mockEnv?['GOOGLE_TRANSLATE_API_KEY'];
}

void main() {
  group('API Key Retrieval', () {
    test('Retrieves API key from .env file', () {
      final envFile = File('.env');
      envFile.writeAsStringSync('GOOGLE_TRANSLATE_API_KEY=test_key');

      final key = getApiKey();
      expect(key, 'test_key');

      envFile.deleteSync(); // Cleanup
    });

    test('Retrieves API key from mocked environment variable', () {
      final key =
          getApiKey(mockEnv: {'GOOGLE_TRANSLATE_API_KEY': 'env_test_key'});
      expect(key, 'env_test_key');
    });
  });
}
