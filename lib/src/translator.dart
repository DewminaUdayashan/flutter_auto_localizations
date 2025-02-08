import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  final String apiKey;
  final List<String> ignorePhrases;

  Translator(this.apiKey, {this.ignorePhrases = const []});

  Future<String> translateText(
      String text, String fromLang, String toLang) async {
    if (ignorePhrases.isEmpty) {
      return _translate(text, fromLang, toLang);
    }

    // Step 1: Replace ignored phrases with placeholders
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

    // Step 2: Translate only the modifiable parts
    String translatedText = await _translate(modifiedText, fromLang, toLang);

    // Step 3: Restore ignored phrases
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
