import 'dart:io';

import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigParser Tests', () {
    test('✅ Loads valid config file', () {
      final testConfigFile = File("config.yaml")..writeAsStringSync("""
default: en
languages:
  - fr
  - es
ignore_phrases:
  - "test"
key_config:
  example_key:
    skipIgnorePhrases: true
""");

      final config = ConfigParser.loadConfig(customPath: "config.yaml");

      expect(config, isNotEmpty);
      expect(config["default"], equals("en"));
      expect(config["languages"], contains("fr"));
      expect(config["ignore_phrases"], contains("test"));

      testConfigFile.deleteSync(); // Cleanup
    });

    test('✅ Handles missing config file', () {
      expect(() => ConfigParser.loadConfig(customPath: "missing.yaml"),
          throwsA(isA<Exception>()));
    });

    test('✅ Parses key-specific ignore phrases correctly', () {
      final testConfigFile = File("config_test.yaml")..writeAsStringSync("""
default: en
languages:
  - es
key_config:
  specific_key:
    ignore_phrases:
      - "exclude"
""");

      final config = ConfigParser.loadConfig(customPath: "config_test.yaml");

      expect(config["key_config"], contains("specific_key"));
      expect(config["key_config"]["specific_key"]["ignore_phrases"],
          contains("exclude"));

      testConfigFile.deleteSync(); // Cleanup
    });
  });
}
