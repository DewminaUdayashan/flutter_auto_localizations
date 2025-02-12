import 'dart:io';

import 'package:flutter_auto_localizations/src/config_parser.dart';
import 'package:test/test.dart';

void main() {
  const configFileName = "l10n.yaml";

  setUp(() {
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
global-ignore-phrases:
  - "test"
key-config:
  exampleKey:
    skip-global-ignore: true
enable-cache: true
""");
  });

  tearDown(() {
    final testConfigFile = File(configFileName);
    if (testConfigFile.existsSync()) {
      testConfigFile.deleteSync();
    }
  });

  group('ConfigParser Tests', () {
    test('✅ Loads valid l10n.yaml file', () {
      final config = ConfigParser.loadConfig();

      expect(config, isNotEmpty);
      expect(config["localization-dir"], equals("lib/l10n"));
      expect(config["template-arb-file"], equals("app_en.arb"));
      expect(config["default-lang"], equals("en"));
      expect(config["languages"], containsAll(["fr", "es"]));
      expect(config["global-ignore-phrases"], contains("test"));
      expect(config["key-config"], contains("exampleKey"));
      expect(config["key-config"]["exampleKey"]["skip-global-ignore"], isTrue);
      expect(config["enable-cache"], isTrue);
    });

    test('✅ Throws exception when l10n.yaml is missing', () {
      File(configFileName).deleteSync();
      expect(() => ConfigParser.loadConfig(), throwsA(isA<Exception>()));
    });
  });
}
