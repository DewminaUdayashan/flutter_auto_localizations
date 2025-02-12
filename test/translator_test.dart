import 'dart:convert';

import 'package:flutter_auto_localizations/src/shared/utils.dart';
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
    // ✅ Initialize `TranslationConfig` BEFORE creating `Translator`
    TranslationConfig.initialize(
      keyConfig: {
        "sampleKey": {"no-cache": false, "ignore": false},
        "ignoredKey": {"ignore": true}, // ✅ Test case for ignored key
        "noCacheKey": {"no-cache": true}, // ✅ Test case for no-cache flag
      },
      globalIgnorePhrases: ["Flutter"], // ✅ Global ignore phrase test
      enableCache: true,
    );

    // ✅ Initialize `Translator` AFTER `TranslationConfig`
    mockHttpClient = MockClient();
    translator = Translator(apiKey, httpClient: mockHttpClient);
  });

  test('✅ Should translate text successfully', () async {
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

    final result = await translator.translateText(key, text, fromLang, toLang);
    expect(result, translatedText);
  });

  test('✅ Should return empty string for empty text', () async {
    final result = await translator.translateText('key', '', 'en', 'es');
    expect(result, equals('')); // ✅ Should return an empty string, not throw
  });

  test('✅ Should skip translation for ignored keys', () async {
    const key = 'ignoredKey';
    const text = 'Do not translate';
    const fromLang = 'en';
    const toLang = 'fr';

    final result = await translator.translateText(key, text, fromLang, toLang);
    expect(result, text); // ✅ Should return the original text
  });

  test('✅ Should always call API when `no-cache` is enabled', () async {
    const key = 'noCacheKey';
    const text = 'Translate this';
    const fromLang = 'en';
    const toLang = 'fr';
    const translatedText = 'Traduire ceci';

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

    final result = await translator.translateText(key, text, fromLang, toLang);
    expect(result, translatedText);
  });

  test('✅ Should apply global ignore phrases', () async {
    const key = 'sentence';
    const text = 'I love Flutter';
    const fromLang = 'en';
    const toLang = 'fr';
    const translatedText = 'J’aime [IGNORE_0]'; // ✅ Mocked API response
    const finalText =
        'J’aime Flutter'; // ✅ Expected output after ignore restoration

    when(mockHttpClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(
                jsonEncode({
                  // ✅ Encode as JSON string correctly
                  'data': {
                    'translations': [
                      {'translatedText': translatedText}
                    ]
                  }
                }),
                200,
                headers: {
                  'content-type': 'application/json; charset=utf-8'
                })); // ✅ Explicit UTF-8 header

    final result = await translator.translateText(key, text, fromLang, toLang);
    expect(result, finalText); // ✅ Flutter should remain unchanged
  });
}
