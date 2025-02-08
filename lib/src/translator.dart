import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  final String apiKey;
  final List<String> globalIgnorePhrases;
  final Map<String, dynamic> keyConfig; // Store per-key settings

  Translator(this.apiKey,
      {this.globalIgnorePhrases = const [], this.keyConfig = const {}});

  Future<String> translateText(
      String key, String text, String fromLang, String toLang) async {
    // Check if key has `skipIgnorePhrases` enabled
    if (keyConfig.containsKey(key) &&
        keyConfig[key]['skipIgnorePhrases'] == true) {
      print("🔹 Skipping ignore phrases check for key: $key");
      return _translate(text, fromLang, toLang);
    }

    // Check if key has its own ignore_phrases
    List<String> ignorePhrases = globalIgnorePhrases;
    if (keyConfig.containsKey(key) &&
        keyConfig[key].containsKey('ignore_phrases')) {
      ignorePhrases = List<String>.from(keyConfig[key]['ignore_phrases']);
    }

    // Replace ignored phrases with placeholders
    Map<String, String> placeholderMap = {};
    String modifiedText = text;

    for (int i = 0; i < ignorePhrases.length; i++) {
      String phrase = ignorePhrases[i];

      if (modifiedText.contains(phrase)) {
        String placeholder = "[IGNORE_$i]";
        placeholderMap[placeholder] = phrase;
        modifiedText = modifiedText.replaceAll(phrase, placeholder);
      }
    }

    // Translate only the modifiable parts
    String translatedText = await _translate(modifiedText, fromLang, toLang);

    // Restore ignored phrases
    placeholderMap.forEach((placeholder, originalText) {
      translatedText = translatedText.replaceAll(placeholder, originalText);
    });

    return translatedText;
  }

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
      throw Exception("Translation failed: ${response.body}");
    }
  }
}
