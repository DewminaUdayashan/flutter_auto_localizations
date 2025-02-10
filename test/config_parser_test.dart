import 'dart:io';

import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';
import 'package:test/test.dart';

void main() {
  const configFileName = "l10n.yaml";

  setUp(() async {
    // Ensure the file is written before any test runs
    final testConfigFile = File(configFileName);
    if (testConfigFile.existsSync()) {
      testConfigFile.deleteSync();
    }

    testConfigFile.writeAsStringSync("""
arb-dir: lib/l10n
template-arb-file: app_en.arb
languages:
  - fr
  - es
global_ignore_phrases:
  - "test"
key_config:
  example_key:
    skipGlobalIgnore: true
""");

    // Ensure file system flush before reading
    await Future.delayed(Duration(milliseconds: 100));
  });

  tearDown(() {
    // Clean up after each test
    final testConfigFile = File(configFileName);
    if (testConfigFile.existsSync()) {
      testConfigFile.deleteSync();
    }
  });

  group('ConfigParser Tests', () {
    test('✅ Loads valid l10n.yaml file', () {
      final config = ConfigParser.loadConfig();

      expect(config, isNotEmpty);
      expect(config["localization_dir"], equals("lib/l10n"));
      expect(config["template_arb_file"], equals("app_en.arb"));
      expect(config["default_lang"], equals("en"));
      expect(config["languages"], containsAll(["fr", "es"]));
      expect(config["global_ignore_phrases"], contains("test"));
      expect(config["key_config"], contains("example_key"));
      expect(config["key_config"]["example_key"]["skipGlobalIgnore"], isTrue);
    });

    test('✅ Throws exception when l10n.yaml is missing', () {
      // Delete file before testing missing case
      final testConfigFile = File(configFileName);
      if (testConfigFile.existsSync()) {
        testConfigFile.deleteSync();
      }

      expect(() => ConfigParser.loadConfig(), throwsA(isA<Exception>()));
    });
  });
}
