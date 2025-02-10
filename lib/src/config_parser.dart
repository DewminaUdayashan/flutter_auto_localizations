import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ConfigParser {
  static Map<String, dynamic> loadConfig() {
    const yamlConfigPath =
        "l10n.yaml"; // Standard Flutter localization config file

    if (!File(yamlConfigPath).existsSync()) {
      throw Exception("❌ No configuration file found: $yamlConfigPath.");
    }

    final content = File(yamlConfigPath).readAsStringSync();
    Map<String, dynamic> config = json
        .decode(json.encode(loadYaml(content))); // Convert YAML to JSON format

    // Ensure ignore_phrases is always a list
    config['ignore_phrases'] = (config.containsKey('ignore_phrases') &&
            config['ignore_phrases'] is List)
        ? List<String>.from(config['ignore_phrases'])
        : <String>[];

    // Ensure key_config exists
    config['key_config'] = config.containsKey('key_config') &&
            config['key_config'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(config['key_config'])
        : <String, dynamic>{};

    return config;
  }
}
