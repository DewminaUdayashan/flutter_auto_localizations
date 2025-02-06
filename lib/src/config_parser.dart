import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ConfigParser {
  static Map<String, dynamic> loadConfig(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("Config file not found: $path");
    }
    final content = file.readAsStringSync();
    if (path.endsWith(".json")) {
      return json.decode(content);
    } else if (path.endsWith(".yaml") || path.endsWith(".yml")) {
      return json.decode(json.encode(loadYaml(content)));
    } else {
      throw Exception("Unsupported config file format.");
    }
  }
}
