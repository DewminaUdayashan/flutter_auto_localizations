import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ConfigParser {
  static const String yamlConfigPath = "translation_config.yaml";
  static const String jsonConfigPath = "translation_config.json";

  static Map<String, dynamic> loadConfig() {
    File? configFile;

    if (File(yamlConfigPath).existsSync()) {
      configFile = File(yamlConfigPath);
      print("✅ Using YAML configuration: $yamlConfigPath");
    } else if (File(jsonConfigPath).existsSync()) {
      configFile = File(jsonConfigPath);
      print("✅ Using JSON configuration: $jsonConfigPath");
    } else {
      throw Exception(
          "❌ No configuration file found. Please create 'translation_config.yaml' or 'translation_config.json'.");
    }

    final content = configFile.readAsStringSync();
    if (configFile.path.endsWith(".yaml") || configFile.path.endsWith(".yml")) {
      return json.decode(
          json.encode(loadYaml(content))); // Convert YAML to JSON format
    } else {
      return json.decode(content);
    }
  }
}
