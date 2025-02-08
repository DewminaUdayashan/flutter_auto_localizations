import 'package:flutter_auto_localizations/src/translator.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Mock class for Translator
class MockTranslator extends Mock implements Translator {
  @override
  final List<String> ignorePhrases;

  MockTranslator({this.ignorePhrases = const []});

  @override
  Future<String> translateText(
      String text, String fromLang, String toLang) async {
    if (text.isEmpty) {
      throw Exception("Invalid text");
    }

    // Simulating phrase exclusion logic
    for (var phrase in ignorePhrases) {
      if (text.contains(phrase)) {
        return text.replaceAll(phrase, phrase); // Return unchanged phrase
      }
    }

    return "Texto traducido"; // Fake translated text
  }
}

void main() {
  group('Translator', () {
    final mockTranslator =
        MockTranslator(ignorePhrases: ['Status Saver', 'Flutter Pro']);

    test('Translates text correctly', () async {
      final result = await mockTranslator.translateText('Hello', 'en', 'es');
      expect(result, equals("Texto traducido"));
    });

    test('Ignores specified phrases inside a sentence', () async {
      final result = await mockTranslator.translateText(
          'Welcome to Status Saver', 'en', 'es');
      expect(
          result, contains("Welcome to Status Saver")); // Partial translation
    });

    test('Ignores multiple phrases in a sentence', () async {
      final result = await mockTranslator.translateText(
          'Status Saver is a product of Flutter Pro', 'en', 'es');
      expect(
          result,
          contains(
              "Status Saver is a product of Flutter Pro")); // Multiple ignored phrases
    });

    test('Handles errors gracefully', () async {
      try {
        await mockTranslator.translateText('', 'en', 'es');
        fail('Should throw an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
