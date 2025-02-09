import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  final String apiKey;
  final List<String> globalIgnorePhrases;
  final Map<String, dynamic> keyConfig;

  Translator(this.apiKey,
      {this.globalIgnorePhrases = const [], this.keyConfig = const {}});

  Future<String> translateText(
      String key, String text, String fromLang, String toLang) async {
    if (text.isEmpty) {
      throw Exception("❌ Error: Cannot translate empty text.");
    }

    // ✅ **Check if `skipIgnorePhrases` is enabled for this key**
    if (keyConfig.containsKey(key) &&
        keyConfig[key]['skipIgnorePhrases'] == true) {
      return _translate(text, fromLang, toLang);
    }

    // ✅ **Handle ICU Plural Messages Separately**
    if (_isICUPluralMessage(text)) {
      return _translateICUPluralMessage(key, text, fromLang, toLang);
    }

    if (_shouldSkipTranslation(text)) return text;

    // ✅ **Apply Ignore Phrases BEFORE translation**
    Map<String, String> placeholderMap = {};
    String modifiedText =
        _applyIgnorePhrasesBeforeTranslation(text, placeholderMap);

    // ✅ **Translate the modified text**
    String translatedText = await _translate(modifiedText, fromLang, toLang);

    // ✅ **Restore ignored phrases AFTER translation**
    translatedText =
        _restoreIgnoredPhrasesAfterTranslation(translatedText, placeholderMap);

    return translatedText;
  }

  /// ✅ **Detects ICU Plural Messages**
  bool _isICUPluralMessage(String text) {
    return text.contains(RegExp(r'{\w+, plural,'));
  }

  /// ✅ **Processes and Translates ICU Plural Messages Correctly**
  Future<String> _translateICUPluralMessage(
      String key, String text, String fromLang, String toLang) async {
    final regex = RegExp(r'\{(\w+), plural, (.+)\}$', dotAll: true);
    final match = regex.firstMatch(text);

    if (match == null) {
      return text; // Return original if no plural pattern detected
    }
    final variable =
        match.group(1)!; // Extract placeholder variable (e.g., "count")
    String pluralRules =
        match.group(2)!; // Extract all rules: zero{}, one{}, other{}

    final translatedRules = <String, String>{};

    // ✅ **Regex to Capture All Plural Rules Properly**
    final ruleRegex = RegExp(r'(\w+)\{((?:[^\{\}]|\{[^\{\}]*\})*)\}');

    for (final ruleMatch in ruleRegex.allMatches(pluralRules)) {
      final ruleType = ruleMatch.group(1)!; // e.g., "zero", "one", "other"
      String ruleText =
          ruleMatch.group(2)!; // e.g., "You have {count} new messages"

      // ✅ **Apply ignore phrases before translation**
      Map<String, String> placeholderMap = {};
      ruleText = _applyIgnorePhrasesBeforeTranslation(ruleText, placeholderMap);
      ruleText = ruleText.replaceAll('{count}', '[COUNT_PLACEHOLDER]');

      // ✅ **Translate the modified text**
      String translatedRuleText = await _translate(ruleText, fromLang, toLang);

      // ✅ **Restore ignored phrases AFTER translation**
      translatedRuleText = _restoreIgnoredPhrasesAfterTranslation(
          translatedRuleText, placeholderMap);
      translatedRuleText =
          translatedRuleText.replaceAll('[COUNT_PLACEHOLDER]', '{count}');

      translatedRules[ruleType] = translatedRuleText;
    }

    // ✅ **Rebuild the ICU plural message format correctly**
    final translatedPluralText =
        '{$variable, plural, ${translatedRules.entries.map((e) => '${e.key}{${e.value}}').join(' ')}}';

    return translatedPluralText;
  }

  /// ✅ **Check whether the text should not be translated at all**
  bool _shouldSkipTranslation(
    String text,
  ) =>
      (keyConfig.containsKey(text)
          ? (keyConfig[text]['skipIgnorePhrases'] != true)
          : true) &&
      globalIgnorePhrases.contains(text);

  /// ✅ **Applies Ignore Phrases Before Translation**
  /// - Replaces ignored words with placeholders before translation.
  /// - Stores original words in `placeholderMap` for later restoration.
  String _applyIgnorePhrasesBeforeTranslation(
      String text, Map<String, String> placeholderMap) {
    if (keyConfig.containsKey(text) &&
        keyConfig[text]['skipIgnorePhrases'] == true) {
      return text; // Skip ignore checks if configured
    }

    String modifiedText = text;

    for (int i = 0; i < globalIgnorePhrases.length; i++) {
      String phrase = globalIgnorePhrases[i];

      if (modifiedText.contains(phrase)) {
        String placeholder = "[IGNORE_$i]";
        placeholderMap[placeholder] = phrase;
        modifiedText = modifiedText.replaceAll(phrase, placeholder);
      }
    }

    return modifiedText;
  }

  /// ✅ **Restores Ignored Phrases After Translation**
  /// - Restores original words using `placeholderMap` after translation.
  String _restoreIgnoredPhrasesAfterTranslation(
      String text, Map<String, String> placeholderMap) {
    placeholderMap.forEach((placeholder, originalText) {
      text = text.replaceAll(placeholder, originalText);
    });

    return text;
  }

  /// ✅ **Calls Google Translate API**
  Future<String> _translate(String text, String fromLang, String toLang) async {
    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey');

    final response = await http.post(url,
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
