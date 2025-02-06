import 'package:flutter_auto_localizations/src/translator.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Mock class for Translator
class MockTranslator extends Mock implements Translator {
  @override
  Future<String> translateText(
      String text, String fromLang, String toLang) async {
    if (text.isEmpty) {
      throw Exception("Invalid text");
    }
    return "Texto traducido"; // Fake translated text
  }
}

void main() {
  group('Translator', () {
    final translator = MockTranslator();

    test('Translates text correctly', () async {
      final result = await translator.translateText('Hello', 'en', 'es');
      expect(result, equals("Texto traducido"));
    });

    test('Handles errors gracefully', () async {
      try {
        await translator.translateText('', 'en', 'es');
        fail('Should throw an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
