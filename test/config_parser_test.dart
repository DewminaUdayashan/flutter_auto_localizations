import 'dart:io';

import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';
import 'package:test/test.dart';

void main() {
  const configFileName = "l10n.yaml";

  setUp(() {
    // Ensure any existing test config is removed before running tests
    final file = File(configFileName);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  tearDown(() {
    // Clean up the test file after each test
    final file = File(configFileName);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('ConfigParser Tests', () {
    test('✅ Loads valid l10n.yaml file', () {
      final config = ConfigParser.loadConfig();

      expect(config, isNotEmpty);
      expect(config["default"], equals("en"));
      expect(config["languages"], containsAll(["fr", "es"]));
      expect(config["ignore_phrases"], contains("test"));
      expect(config["key_config"], contains("example_key"));
      expect(config["key_config"]["example_key"]["skipIgnorePhrases"], isTrue);
    });

    test('✅ Throws exception when l10n.yaml is missing', () {
      expect(() => ConfigParser.loadConfig(), throwsA(isA<Exception>()));
    });

    test('✅ Parses key-specific ignore phrases correctly', () {
      final config = ConfigParser.loadConfig();

      expect(config["key_config"], contains("specific_key"));
      expect(config["key_config"]["specific_key"]["ignore_phrases"],
          contains("exclude"));
    });
  });
}
