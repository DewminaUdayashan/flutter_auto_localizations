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

    // Extract localization directory from `arb-dir` key
    final localizationDir =
        config.containsKey('arb-dir') ? config['arb-dir'] : "lib/l10n";

    // Extract template ARB file
    final templateArbFile = config.containsKey('template-arb-file')
        ? config['template-arb-file']
        : "app_en.arb";

    // Extract default language from the filename (assumes format like `app_en.arb`)
    final defaultLang = templateArbFile.split('_').last.split('.').first;

    if (defaultLang.isEmpty) {
      throw Exception(
          "❌ Invalid template-arb-file format: $templateArbFile. Expected format: app_<lang>.arb");
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

    // Inject dynamically parsed values
    config['localization_dir'] = localizationDir;
    config['template_arb_file'] = templateArbFile;
    config['default_lang'] = defaultLang;

    return config;
  }
}
