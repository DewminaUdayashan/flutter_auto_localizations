import 'dart:convert';

import 'translation_config.dart';

/// Utility class for handling translation-related operations.
///
/// Provides methods for generating cache keys and retrieving ignore phrases
/// for specific translation keys.
class TranslationUtils {
  /// Generates a unique cache key for translations.
  ///
  /// This key is created using the source language, target language, input text,
  /// and additional translation settings.
  ///
  /// - [fromLang]: The source language code (e.g., `"en"`).
  /// - [toLang]: The target language code (e.g., `"es"`).
  /// - [text]: The text to be translated.
  /// - [key]: The translation key used for configuration-based rules.
  ///
  /// Returns a JSON-encoded string that uniquely represents the translation request.
  ///
  /// Example:
  /// ```dart
  /// String cacheKey = TranslationUtils.generateCacheKey(
  ///   fromLang: "en",
  ///   toLang: "fr",
  ///   text: "Hello",
  ///   key: "greeting",
  /// );
  /// print(cacheKey);
  /// ```
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

  /// Retrieves the list of phrases to be ignored for a given translation key.
  ///
  /// - [key]: The translation key for which ignore phrases should be retrieved.
  ///
  /// This method merges global ignore phrases with key-specific ignore phrases
  /// unless the key is configured to skip global ignores.
  ///
  /// Returns a list of phrases that should not be translated.
  ///
  /// Example:
  /// ```dart
  /// List<String> ignored = TranslationUtils._getIgnorePhrasesForKey("greeting");
  /// print(ignored); // ['test', 'example']
  /// ```
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
