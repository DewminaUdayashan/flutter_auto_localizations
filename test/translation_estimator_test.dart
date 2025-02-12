import 'dart:convert';
import 'dart:io';

import 'package:flutter_auto_localizations/src/shared/utils.dart';
import 'package:flutter_auto_localizations/src/translation_estimator.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // ✅ Ensure TranslationConfig is initialized before tests
    TranslationConfig.initialize(
      keyConfig: {
        "sampleKey": {
          "no-cache": false,
          "ignore": false,
        }
      },
      globalIgnorePhrases: ["ignoreMe"],
      enableCache: true,
    );
  });

  group('TranslationEstimator Tests', () {
    const testArbFile = "test_valid.arb";
    const missingArbFile = "non_existent.arb";

    setUp(() {
      // ✅ Create a sample ARB file for testing
      final file = File(testArbFile);
      file.writeAsStringSync(jsonEncode({
        "@@locale": "en",
        "hello": "Hello, world!",
        "ignoredKey": "This should be ignored",
      }));
    });

    tearDown(() {
      // ✅ Cleanup test files
      final file = File(testArbFile);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('✅ Handles missing ARB file gracefully', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator()
              .estimateTranslationCost(missingArbFile, targetLanguages),
          prints(contains("❌ Error: ARB file not found")));
    });

    test('✅ Estimates translation cost correctly', () {
      List<String> targetLanguages = ["es", "fr"];
      expect(
          () => TranslationEstimator()
              .estimateTranslationCost(testArbFile, targetLanguages),
          prints(contains("💰 Estimated Total Cost: ")));
    });

    test('✅ Uses cache correctly to reduce API calls', () {
      TranslationConfig.initialize(
        keyConfig: {
          "hello": {"no-cache": false},
        },
        globalIgnorePhrases: [],
        enableCache: true,
      );

      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator()
              .estimateTranslationCost(testArbFile, targetLanguages),
          prints(contains("💾 Cached Characters: ")));
    });

    test('✅ Ensures pricing link appears in logs', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator()
              .estimateTranslationCost(testArbFile, targetLanguages),
          prints(contains(
              "🔗 More details on pricing: https://cloud.google.com/translate/pricing#basic-pricing")));
    });

    test('✅ Correctly formats numbers with thousands separator', () {
      expect(TranslationEstimator.formatNumber(1000), equals("1,000"));
      expect(TranslationEstimator.formatNumber(1000000), equals("1,000,000"));
    });
  });
}
