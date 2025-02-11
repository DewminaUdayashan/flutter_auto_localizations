import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  final String apiKey;
  final List<String> globalIgnorePhrases;
  final Map<String, dynamic> keyConfig;
  final http.Client httpClient; // ✅ Inject HTTP client for testing

  Translator(
    this.apiKey, {
    this.globalIgnorePhrases = const [],
    this.keyConfig = const {},
    http.Client? httpClient, // Optional, allows injection
  }) : httpClient =
            httpClient ?? http.Client(); // ✅ Default to real HTTP client

  Future<String> translateText(
    String key,
    String text,
    String fromLang,
    String toLang,
  ) async {
    if (text.isEmpty) {
      throw Exception("❌ Error: Cannot translate empty text.");
    }

    // ✅ Handle ICU Messages
    if (_isICUPlural(text)) {
      return _processICUMessage(key, text, fromLang, toLang, "plural");
    }
    if (_isICUSelect(text)) {
      return _processICUMessage(key, text, fromLang, toLang, "select");
    }

    if (_shouldSkipTranslation(key, text)) return text;

    // ✅ Apply Ignore Phrases BEFORE translation
    Map<String, String> placeholderMap = {};
    final modifiedText =
        _replaceIgnorePhrasesWithPlaceholders(key, text, placeholderMap);

    // ✅ Translate the modified text
    String translatedText = await _translate(modifiedText, fromLang, toLang);

    // ✅ Restore ignored phrases AFTER translation
    translatedText = _restorePlaceholders(translatedText, placeholderMap);

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
    print(modifiedText);
    final translatedText = await _translate(modifiedText, fromLang, toLang);
    return _restorePlaceholders(translatedText, placeholderMap);
  }

  /// ✅ Determines if translation should be skipped
  bool _shouldSkipTranslation(String key, String text) {
    return _getIgnorePhrasesForKey(key).contains(text);
  }

  /// ✅ Retrieves ignore phrases for a given key (Merges global + per-key)
  List<String> _getIgnorePhrasesForKey(String key) {
    final perKeyIgnorePhrases = keyConfig.containsKey(key) &&
            keyConfig[key]['key_ignore_phrases'] is List
        ? List<String>.from(keyConfig[key]['key_ignore_phrases'])
        : <String>[];

    return keyConfig.containsKey(key) &&
            keyConfig[key]['skipGlobalIgnore'] == true
        ? perKeyIgnorePhrases
        : [...globalIgnorePhrases, ...perKeyIgnorePhrases];
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
