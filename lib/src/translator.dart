import 'dart:convert';

import 'package:http/http.dart' as http;

class Translator {
  final String apiKey;

  Translator(this.apiKey);

  Future<String> translateText(
      String text, String fromLang, String toLang) async {
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
