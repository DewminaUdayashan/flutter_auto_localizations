import 'dart:convert';

import 'package:flutter_auto_localizations/src/translator.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'translator_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late Translator translator;
  const apiKey = 'test-api-key';

  setUp(() {
    mockHttpClient = MockClient();
    translator = Translator(apiKey, httpClient: mockHttpClient);
  });

  group('translateText', () {
    test('should translate text successfully', () async {
      const key = 'greeting';
      const text = 'Hello';
      const fromLang = 'en';
      const toLang = 'es';
      const translatedText = 'Hola';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': {
                  'translations': [
                    {'translatedText': translatedText}
                  ]
                }
              }),
              200));

      final result =
          await translator.translateText(key, text, fromLang, toLang);
      expect(result, translatedText);
    });

    test('should throw an error for empty text', () {
      expect(() => translator.translateText('key', '', 'en', 'es'),
          throwsException);
    });

    test('should handle ICU plural messages', () async {
      const key = 'items_count';
      const text = '{count, plural, one{1 item} other{# item}}';
      const fromLang = 'en';
      const toLang = 'fr';
      const translatedText = '{count, plural, one{1 item} other{1 item}}';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': {
                  'translations': [
                    {'translatedText': '1 item'}
                  ]
                }
              }),
              200));

      final result =
          await translator.translateText(key, text, fromLang, toLang);
      expect(result, translatedText);
    });

    test('should handle ignore phrases correctly', () async {
      final translator = Translator(apiKey,
          httpClient: mockHttpClient, globalIgnorePhrases: ['Flutter']);
      const key = 'sentence';
      const text = 'I love Flutter';
      const fromLang = 'en';
      const toLang = 'fr';
      const translatedText = 'Jaime [IGNORE_0]';
      const finalText = 'Jaime Flutter';

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': {
                  'translations': [
                    {'translatedText': translatedText}
                  ]
                }
              }),
              200));

      final result =
          await translator.translateText(key, text, fromLang, toLang);
      expect(result, finalText);
    });

    test('should handle API failure', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => translator.translateText('key', 'Hello', 'en', 'es'),
          throwsException);
    });
  });
}
