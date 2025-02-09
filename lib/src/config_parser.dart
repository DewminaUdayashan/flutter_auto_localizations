import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ConfigParser {
  static Map<String, dynamic> loadConfig({String? customPath}) {
    final yamlConfigPath = customPath ?? "translation_config.yaml";
    final jsonConfigPath = customPath ?? "translation_config.json";

    File? configFile;

    if (File(yamlConfigPath).existsSync()) {
      configFile = File(yamlConfigPath);
      print("✅ Using YAML configuration: $yamlConfigPath");
    } else if (File(jsonConfigPath).existsSync()) {
      configFile = File(jsonConfigPath);
      print("✅ Using JSON configuration: $jsonConfigPath");
    } else {
      throw Exception(
          "❌ No configuration file found at $yamlConfigPath or $jsonConfigPath.");
    }

    final content = configFile.readAsStringSync();
    Map<String, dynamic> config;

    if (configFile.path.endsWith(".yaml") || configFile.path.endsWith(".yml")) {
      config = json.decode(
          json.encode(loadYaml(content))); // Convert YAML to JSON format
    } else {
      config = json.decode(content);
    }

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
