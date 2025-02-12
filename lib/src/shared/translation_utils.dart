import 'dart:convert';

import 'translation_config.dart';

class TranslationUtils {
  /// ✅ Generates a consistent cache key for translations
  static String generateCacheKey({
    required String fromLang,
    required String toLang,
    required String text,
    required String key,
  }) {
    final config = TranslationConfig.instance; // Use initialized instance

    final perKeyConfig = config.keyConfig[key] ?? {};
    final List<String> ignorePhrases = _getIgnorePhrasesForKey(key);
    final bool skipGlobalIgnore = perKeyConfig['skip-global-ignore'] ?? false;

    return jsonEncode({
      "fromLang": fromLang,
      "toLang": toLang,
      "text": text,
      "ignorePhrases": ignorePhrases, // Includes both global and per-key
      "skipGlobalIgnore": skipGlobalIgnore // Flag included in cache key
    });
  }

  /// ✅ Retrieves ignore phrases for a given key (Merges global + per-key)
  static List<String> _getIgnorePhrasesForKey(String key) {
    final config = TranslationConfig.instance; // Use singleton instance
    final perKeyIgnorePhrases = config.keyConfig.containsKey(key) &&
            config.keyConfig[key]['key-ignore-phrases'] is List
        ? List<String>.from(config.keyConfig[key]['key-ignore-phrases'])
        : <String>[];

    return config.keyConfig.containsKey(key) &&
            config.keyConfig[key]['skip-global-ignore'] == true
        ? perKeyIgnorePhrases
        : [...config.globalIgnorePhrases, ...perKeyIgnorePhrases];
  }
}
