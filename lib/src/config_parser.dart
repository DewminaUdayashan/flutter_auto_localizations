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

    // Load global ignore phrases
    List<String> globalIgnorePhrases =
        config.containsKey('global_ignore_phrases')
            ? List<String>.from(config['global_ignore_phrases'])
            : <String>[];

    // Load key-specific ignore configurations
    Map<String, dynamic> keyConfig = config.containsKey('key_config') &&
            config['key_config'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(config['key_config'])
        : <String, dynamic>{};

    // Ensure structure of key_config is correct
    keyConfig.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        // Ensure `key_ignore_phrases` is a list
        if (value.containsKey('key_ignore_phrases') &&
            value['key_ignore_phrases'] is List) {
          value['key_ignore_phrases'] =
              List<String>.from(value['key_ignore_phrases']);
        } else {
          value['key_ignore_phrases'] = <String>[];
        }

        // Ensure `skipGlobalIgnore` and `skipKeyIgnore` are booleans
        value['skipGlobalIgnore'] = value.containsKey('skipGlobalIgnore')
            ? value['skipGlobalIgnore'] == true
            : false;
        value['skipKeyIgnore'] = value.containsKey('skipKeyIgnore')
            ? value['skipKeyIgnore'] == true
            : false;
      }
    });

    // Read cache setting, default to true if not specified
    final enableCache = config.containsKey('enable_cache')
        ? config['enable_cache'] == true
        : true;

    // Inject dynamically parsed values
    config['localization_dir'] = localizationDir;
    config['template_arb_file'] = templateArbFile;
    config['default_lang'] = defaultLang;
    config['global_ignore_phrases'] = globalIgnorePhrases;
    config['key_config'] = keyConfig;
    config['enable_cache'] = enableCache;

    return config;
  }
}
