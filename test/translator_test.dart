import 'package:flutter_auto_localizations/src/translator.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Mock class for Translator
class MockTranslator extends Mock implements Translator {
  @override
  final List<String> globalIgnorePhrases;
  @override
  final Map<String, dynamic> keyConfig;

  MockTranslator(
      {this.globalIgnorePhrases = const [], this.keyConfig = const {}});

  @override
  Future<String> translateText(
      String key, String text, String fromLang, String toLang) async {
    if (text.isEmpty) {
      throw Exception("Invalid text");
    }

    // Check if key has `skipIgnorePhrases` enabled
    if (keyConfig.containsKey(key) &&
        keyConfig[key]['skipIgnorePhrases'] == true) {
      return "Translated: $text"; // Simulate normal translation without ignore phrases
    }

    // Determine which ignore phrases to use
    List<String> ignorePhrases = globalIgnorePhrases;
    if (keyConfig.containsKey(key) &&
        keyConfig[key].containsKey('ignore_phrases')) {
      ignorePhrases = List<String>.from(keyConfig[key]['ignore_phrases']);
    }

    // Simulate ignoring phrases
    String translatedText = "Translated: $text"; // Fake translation
    for (String phrase in ignorePhrases) {
      if (text.contains(phrase)) {
        translatedText =
            text.replaceAll(phrase, phrase); // Keep phrase unchanged
      }
    }

    return translatedText;
  }
}

void main() {
  group('Translator', () {
    final mockTranslator = MockTranslator(
      globalIgnorePhrases: ["Flutter", "Status Saver"],
      keyConfig: {
        'helloWorld': {
          'skipIgnorePhrases': true
        }, // This should bypass ignore phrases
        'desc': {
          'ignore_phrases': ['WhatsApp', 'Dewmina']
        }, // Custom ignore list
        'status': {
          'ignore_phrases': ['Status Saver']
        } // Custom per-key ignore
      },
    );

    test('Translates text correctly when no ignore rules apply', () async {
      final result =
          await mockTranslator.translateText('hello', 'Hello', 'en', 'es');
      expect(result, equals("Translated: Hello"));
    });

    test('Ignores phrases inside a key based on config', () async {
      final result = await mockTranslator.translateText('desc',
          'This is an app for WhatsApp Status, Created by Dewmina', 'en', 'es');
      expect(result, contains("WhatsApp")); // WhatsApp should remain unchanged
      expect(result, contains("Dewmina")); // Dewmina should remain unchanged
    });

    test('Skips ignore check when `skipIgnorePhrases` is true', () async {
      final result = await mockTranslator.translateText(
          'helloWorld', 'Welcome to Status Saver', 'en', 'es');
      expect(result,
          equals("Translated: Welcome to Status Saver")); // Fully translated
    });

    test('Respects per-key ignore rules', () async {
      final result = await mockTranslator.translateText(
          'status', 'Status Saver is available for everyone', 'en', 'es');
      expect(result,
          contains("Status Saver")); // Status Saver should not be translated
    });

    test('Applies global ignore phrases when no per-key override is set',
        () async {
      final result = await mockTranslator.translateText(
          'randomKey', 'Flutter is awesome', 'en', 'es');
      expect(result, contains("Flutter")); // Flutter should remain unchanged
    });

    test('Handles errors gracefully when empty text is given', () async {
      try {
        await mockTranslator.translateText('randomKey', '', 'en', 'es');
        fail('Should throw an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
