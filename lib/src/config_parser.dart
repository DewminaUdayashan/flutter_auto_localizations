import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// A utility class for parsing and loading Flutter localization configurations.
///
/// The `ConfigParser` reads settings from a `l10n.yaml` file, which is commonly used
/// in Flutter projects for localization setup. It extracts essential configurations
/// such as the ARB directory, template ARB file, default language, and other custom settings.
///
/// Example usage:
/// ```dart
/// final config = ConfigParser.loadConfig();
/// print(config['localization-dir']); // Output: "lib/l10n"
/// ```
class ConfigParser {
  /// Loads and parses the `l10n.yaml` configuration file.
  ///
  /// This method reads the YAML configuration file, converts it into a JSON-compatible
  /// `Map<String, dynamic>`, and extracts the following properties:
  ///
  /// - `arb-dir`: Directory containing ARB files (default: `"lib/l10n"`).
  /// - `template-arb-file`: The main ARB template file (default: `"app_en.arb"`).
  /// - `default-lang`: The default language extracted from the template filename.
  /// - `global-ignore-phrases`: A list of phrases to ignore globally.
  /// - `key-config`: Configuration for individual translation keys.
  /// - `enable-cache`: Whether caching is enabled (default: `true`).
  ///
  /// Throws an [Exception] if the configuration file does not exist or if
  /// `template-arb-file` has an invalid format.
  ///
  /// Returns a `Map<String, dynamic>` containing parsed configuration values.
  static Map<String, dynamic> loadConfig() {
    const yamlConfigPath =
        "l10n.yaml"; // Standard Flutter localization config file

    if (!File(yamlConfigPath).existsSync()) {
      throw Exception("❌ No configuration file found: $yamlConfigPath.");
    }

    final content = File(yamlConfigPath).readAsStringSync();
    final config = json
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
          "❌ Invalid template-arb-file format: $templateArbFile. Expected format: app-<lang>.arb");
    }

    // ✅ Handle missing `global-ignore-phrases`
    final globalIgnorePhrases = config.containsKey('global-ignore-phrases') &&
            config['global-ignore-phrases'] is List
        ? List<String>.from(config['global-ignore-phrases'])
        : <String>[];

    // ✅ Handle `key-config`, ensuring it contains valid structures
    final keyConfig =
        config.containsKey('key-config') && config['key-config'] is Map
            ? Map<String, dynamic>.from(config['key-config'])
            : <String, dynamic>{};

    // Ensure structure of `key-config` is correct
    keyConfig.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        value['key-ignore-phrases'] = value.containsKey('key-ignore-phrases') &&
                value['key-ignore-phrases'] is List
            ? List<String>.from(value['key-ignore-phrases'])
            : <String>[];

        value['skip-global-ignore'] = value.containsKey('skip-global-ignore')
            ? value['skip-global-ignore'] == true
            : false;

        value['skip-key-ignore'] = value.containsKey('skip-key-ignore')
            ? value['skip-key-ignore'] == true
            : false;

        // ✅ Handle `no-cache` & `ignore`
        value['no-cache'] =
            value.containsKey('no-cache') ? value['no-cache'] == true : false;
        value['ignore'] =
            value.containsKey('ignore') ? value['ignore'] == true : false;
      }
    });

    // Read cache setting, default to true if not specified
    final enableCache = config.containsKey('enable-cache')
        ? config['enable-cache'] == true
        : true;

    // Inject dynamically parsed values
    config['localization-dir'] = localizationDir;
    config['template-arb-file'] = templateArbFile;
    config['default-lang'] = defaultLang;
    config['global-ignore-phrases'] = globalIgnorePhrases;
    config['key-config'] = keyConfig;
    config['enable-cache'] = enableCache;

    return config;
  }
}
