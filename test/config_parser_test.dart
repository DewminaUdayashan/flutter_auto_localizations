import 'dart:io';

import 'package:flutter_auto_localizations/src/config_parser.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigParser', () {
    late File jsonFile;
    late File yamlFile;

    setUp(() {
      jsonFile = File('test/test_config.json');
      jsonFile.writeAsStringSync('''
      {
        "default": "en",
        "languages": ["es", "fr", "de"],
        "run_pub_get": true
      }
      ''');

      yamlFile = File('test/test_config.yaml');
      yamlFile.writeAsStringSync('''
      default: en
      languages:
        - es
        - fr
        - de
      run_pub_get: true
      ''');
    });

    tearDown(() {
      if (jsonFile.existsSync()) jsonFile.deleteSync();
      if (yamlFile.existsSync()) yamlFile.deleteSync();
    });

    test('Loads JSON config file correctly', () {
      final config =
          ConfigParser.loadConfig(customPath: 'test/test_config.json');
      expect(config['default'], 'en');
      expect(config['languages'], containsAll(['es', 'fr', 'de']));
      expect(config['run_pub_get'], true);
    });

    test('Loads YAML config file correctly', () {
      final config =
          ConfigParser.loadConfig(customPath: 'test/test_config.yaml');
      expect(config['default'], 'en');
      expect(config['languages'], containsAll(['es', 'fr', 'de']));
      expect(config['run_pub_get'], true);
    });
  });
}
