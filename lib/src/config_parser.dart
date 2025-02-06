import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ConfigParser {
  static Map<String, dynamic> loadConfig({String? customPath}) {
    final String yamlConfigPath = customPath ?? "translation_config.yaml";
    final String jsonConfigPath = customPath ?? "translation_config.json";

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
    if (configFile.path.endsWith(".yaml") || configFile.path.endsWith(".yml")) {
      return json.decode(
          json.encode(loadYaml(content))); // Convert YAML to JSON format
    } else {
      return json.decode(content);
    }
  }
}
