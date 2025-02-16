import 'dart:convert';

import 'package:flutter_auto_localizations/src/shared/utils.dart';
import 'package:http/http.dart' as http;

import 'cache_manager.dart';

/// A utility class for handling text translations using the Google Translate API.
///
/// The `Translator` class provides methods to translate text between languages,
/// manage translation caching, and handle special cases like ICU messages and ignored phrases.
///
/// Example usage:
/// ```dart
/// final translator = Translator("YOUR_API_KEY");
/// final translatedText = await translator.translateText("greeting", "Hello", "en", "es");
/// print(translatedText); // Output: "Hola"
/// ```
class Translator {
  /// Creates an instance of `Translator` with an API key.
  ///
  /// - [apiKey]: The API key for Google Translate.
  /// - [cacheManager]: Optional, allows injecting a custom `CacheManager` instance.
  /// - [httpClient]: Optional, allows injecting an HTTP client for testing.
  Translator(
    this.apiKey, {
    CacheManager? cacheManager,
    http.Client? httpClient, // Optional, allows injection
  })  : httpClient = httpClient ?? http.Client(),
        cacheManager = cacheManager ??
            CacheManager(
              enableCache: TranslationConfig.instance.enableCache,
            );

  /// The API key used for Google Translate API requests.
  final String apiKey;

  /// The HTTP client used for making API requests.
  final http.Client httpClient;

  /// The cache manager used for storing and retrieving translations.
  final CacheManager cacheManager;

  /// Shared translation configuration instance.
  final config = TranslationConfig.instance; // Access shared config

  /// Translates a given text from [fromLang] to [toLang].
  ///
  /// - [key]: The translation key.
  /// - [text]: The text to be translated.
  /// - [fromLang]: The source language code.
  /// - [toLang]: The target language code.
  ///
  /// This method:
  /// - **Checks the cache** before making an API request.
  /// - **Handles ICU messages** (`plural` and `select`).
  /// - **Respects ignored phrases**.
  /// - **Calls Google Translate API** if needed.
  ///
  /// Returns the translated text.
  ///
  /// Example:
  /// ```dart
  /// final translation = await translator.translateText("greeting", "Hello", "en", "es");
  /// print(translation); // Output: "Hola"
  /// ```
  Future<String> translateText(
    String key,
    String text,
    String fromLang,
    String toLang,
  ) async {
    if (text.isEmpty) return text;

    final perKeyConfig = config.keyConfig[key] ?? {};
    final bool isIgnored = perKeyConfig['ignore'] ?? false;
    final bool noCache = perKeyConfig['no-cache'] ?? false;

    if (isIgnored) return text; // ✅ Skip translation if `ignore` is true

    final cacheKey = TranslationUtils.generateCacheKey(
      fromLang: fromLang,
      toLang: toLang,
      text: text,
      key: key,
    );

    // ✅ Check Cache First
    if (!noCache && cacheManager.hasTranslation(cacheKey)) {
      return cacheManager.getTranslation(cacheKey)!;
    }

    late String translatedText;

    // ✅ Handle ICU Messages
    if (_isICUPlural(text)) {
      translatedText =
          await _processICUMessage(key, text, fromLang, toLang, "plural");
      // ✅ Store in Cache
      if (!noCache) {
        cacheManager.saveTranslation(cacheKey, translatedText);
      }
      return translatedText;
    }
    if (_isICUSelect(text)) {
      translatedText =
          await _processICUMessage(key, text, fromLang, toLang, "select");
      // ✅ Store in Cache
      if (!noCache) {
        cacheManager.saveTranslation(cacheKey, translatedText);
      }
      return translatedText;
    }

    if (_shouldSkipTranslation(key, text)) return text;

    // ✅ Apply Ignore Phrases BEFORE translation
    Map<String, String> placeholderMap = {};
    translatedText =
        _replaceIgnorePhrasesWithPlaceholders(key, text, placeholderMap);

    // ✅ Translate the modified text
    translatedText = await _translate(translatedText, fromLang, toLang);

    // ✅ Restore ignored phrases AFTER translation
    translatedText = _restorePlaceholders(translatedText, placeholderMap);

    // ✅ Store in Cache
    if (!noCache) {
      cacheManager.saveTranslation(cacheKey, translatedText);
    }

    return translatedText;
  }

  /// ✅ Detects ICU Select Messages
  bool _isICUSelect(String text) {
    return text.contains(RegExp(r'{\w+, select,'));
  }

  /// ✅ Detects ICU Plural Messages
  bool _isICUPlural(String text) {
    return text.contains(RegExp(r'{\w+, plural,'));
  }

  /// ✅ Processes and Translates ICU Messages (Plural or Select)
  Future<String> _processICUMessage(
    String key,
    String text,
    String fromLang,
    String toLang,
    String type,
  ) async {
    final regex = RegExp(r'\{(\w+), ' + type + r',\s*(.+)\}$', dotAll: true);
    final match = regex.firstMatch(text);

    if (match == null) {
      return text;
    }

    final variable = match.group(1)!;
    final rules = match.group(2)!;

    final translatedRules = <String, String>{};
    final ruleRegex = RegExp(r'([=\w]+)\s*\{((?:[^{},]|\{[^{}]*\})*)\}');

    for (final ruleMatch in ruleRegex.allMatches(rules)) {
      final ruleType = ruleMatch.group(1)!;
      final ruleText = ruleMatch.group(2)!;

      // ✅ Check if the rule contains an ignored phrase, and skip translation if needed
      if (_shouldSkipTranslation(key, ruleText)) {
        translatedRules[ruleType] = ruleText;
        continue;
      }

      translatedRules[ruleType] =
          await _translateTextSegment(ruleText, fromLang, toLang, key);
    }

    return '{$variable, $type, ${translatedRules.entries.map((e) => '${e.key}{${e.value}}').join(' ')}}';
  }

  /// ✅ Translates a text segment while handling placeholders
  Future<String> _translateTextSegment(
    String text,
    String fromLang,
    String toLang,
    String key,
  ) async {
    final Map<String, String> placeholderMap = {};
    String modifiedText =
        _replaceIgnorePhrasesWithPlaceholders(key, text, placeholderMap);
    final translatedText = await _translate(modifiedText, fromLang, toLang);
    return _restorePlaceholders(translatedText, placeholderMap);
  }

  /// ✅ Determines if translation should be skipped
  bool _shouldSkipTranslation(String key, String text) {
    return _getIgnorePhrasesForKey(key).contains(text);
  }

  /// ✅ Retrieves ignore phrases for a given key (Merges global + per-key)
  List<String> _getIgnorePhrasesForKey(String key) {
    final keyConfig = config.keyConfig;

    final perKeyIgnorePhrases = keyConfig.containsKey(key) &&
            keyConfig[key]['key-ignore-phrases'] is List
        ? List<String>.from(keyConfig[key]['key-ignore-phrases'])
        : <String>[];

    return keyConfig.containsKey(key) &&
            keyConfig[key]['skip-global-ignore'] == true
        ? perKeyIgnorePhrases
        : [...config.globalIgnorePhrases, ...perKeyIgnorePhrases];
  }

  /// ✅ Replaces ignore phrases with placeholders before translation
  String _replaceIgnorePhrasesWithPlaceholders(
    String key,
    String text,
    Map<String, String> placeholderMap,
  ) {
    // ✅ Protect ICU variables like {name}, {count}, etc.
    // If this isn't implemented, some time the placeholders of ICU messages
    // gets translated if it is the only word in the message
    final icuVariableRegex = RegExp(r'\{(\w+)\}');
    text = text.replaceAllMapped(icuVariableRegex, (match) {
      final placeholder = "[ICU_${match.group(1)}]";
      placeholderMap[placeholder] =
          match.group(0)!; // Store the original {name}, {count}, etc.
      return placeholder;
    });

    // ✅ Replace ignore phrases normally
    final ignorePhrases = _getIgnorePhrasesForKey(key);
    for (int i = 0; i < ignorePhrases.length; i++) {
      final phrase = ignorePhrases[i];

      if (text.contains(phrase)) {
        final placeholder = "[IGNORE_$i]";
        placeholderMap[placeholder] = phrase;
        text = text.replaceAll(phrase, placeholder);
      }
    }

    return text;
  }

  /// ✅ Restores placeholders after translation
  String _restorePlaceholders(String text, Map<String, String> placeholderMap) {
    placeholderMap.forEach((placeholder, originalText) {
      text = text.replaceAll(placeholder, originalText);
    });

    return text;
  }

  /// ✅ Calls Google Translate API
  Future<String> _translate(String text, String fromLang, String toLang) async {
    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey');

    final response = await httpClient.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "q": text,
          "source": fromLang,
          "target": toLang,
          "format": "text"
        }));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded["data"]["translations"][0]["translatedText"];
    } else {
      throw Exception("❌ Translation failed: ${response.body}");
    }
  }
}
