import 'package:flutter_auto_localizations/src/translation_estimator.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationEstimator Tests (Full Coverage)', () {
    const validFile = "test/fixtures/test_valid.arb";
    const emptyFile = "test/fixtures/test_empty.arb";
    const largeFile = "test/fixtures/test_large.arb";
    const invalidFile = "test/fixtures/test_invalid.arb";
    const missingFile = "test/fixtures/non_existent.arb";

    test('✅ Correctly calculates characters from a valid ARB file', () {
      List<String> targetLanguages = ["es", "fr"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              validFile, targetLanguages),
          prints(contains("💰 Estimated Total Cost: ")));
    });

    test('✅ Handles empty ARB file correctly', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              emptyFile, targetLanguages),
          prints(contains("🔤 Estimated Total Characters: 0")));
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              emptyFile, targetLanguages),
          prints(contains("💰 Estimated Total Cost: \$0.00")));
    });

    test('✅ Handles missing ARB file gracefully', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              missingFile, targetLanguages),
          prints(contains("❌ Error: ARB file not found")));
    });

    test('✅ Handles invalid JSON in ARB file gracefully', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              invalidFile, targetLanguages),
          throwsA(isA<FormatException>()));
    });

    test('✅ Handles large ARB file correctly', () {
      List<String> targetLanguages = ["es", "fr"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              largeFile, targetLanguages),
          prints(contains("💰 Estimated Total Cost: ")));
    });

    test('✅ Correctly estimates free tier translations (0 cost)', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              validFile, targetLanguages),
          prints(contains("💰 Estimated Total Cost: \$0.00")));
    });

    test('✅ Correctly estimates exceeding free tier translations', () {
      List<String> targetLanguages = ["es", "fr"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              largeFile, targetLanguages),
          prints(contains("💰 Estimated Total Cost: ")));
    });

    test('✅ Ensures pricing link appears in logs', () {
      List<String> targetLanguages = ["es"];
      expect(
          () => TranslationEstimator.estimateTranslationCost(
              validFile, targetLanguages),
          prints(contains(
              "🔗 More details on pricing: https://cloud.google.com/translate/pricing#basic-pricing")));
    });

    test('✅ Correctly formats numbers with thousands separator', () {
      expect(TranslationEstimator.formatNumber(1000), equals("1,000"));
      expect(TranslationEstimator.formatNumber(1000000), equals("1,000,000"));
    });
  });
}
