import 'dart:io';

import 'package:flutter_auto_localizations/src/cache_manager.dart';
import 'package:test/test.dart';

void main() {
  group('CacheManager Tests', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager();
    });

    test('✅ Saves and retrieves cached translation', () {
      cacheManager.saveTranslation("hello", "Bonjour");
      expect(cacheManager.hasTranslation("hello"), isTrue);
      expect(cacheManager.getTranslation("hello"), equals("Bonjour"));
    });

    test('✅ Clears cache correctly', () {
      cacheManager.saveTranslation("test", "Test");
      cacheManager.clearCache();
      expect(cacheManager.hasTranslation("test"), isFalse);
    });

    test('✅ Ensures `.cache/` directory exists', () {
      final directory = Directory('.cache');
      expect(directory.existsSync(), isTrue);
    });
  });
}
