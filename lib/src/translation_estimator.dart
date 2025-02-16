import 'dart:convert';
import 'dart:io';

import 'package:flutter_auto_localizations/src/shared/utils.dart';

import 'cache_manager.dart';

/// A utility class to estimate translation costs based on ARB file content.
///
/// The `TranslationEstimator` analyzes an ARB localization file and calculates
/// the total number of characters that need to be translated into target languages.
/// It factors in previously cached translations to estimate API call costs.
///
/// Example usage:
/// ```dart
/// final estimator = TranslationEstimator();
/// estimator.estimateTranslationCost("lib/l10n/app_en.arb", ["es", "fr"]);
/// ```
class TranslationEstimator {
  /// Creates an instance of `TranslationEstimator` with an optional [cacheManager].
  ///
  /// If no `CacheManager` is provided, it uses a default instance configured
  /// based on `TranslationConfig.instance.enableCache`.
  TranslationEstimator({
    CacheManager? cacheManager,
  }) : cacheManager = cacheManager ??
            CacheManager(enableCache: TranslationConfig.instance.enableCache);

  /// The cache manager used to check for already translated strings.
  final CacheManager cacheManager;

  /// Free tier limit for Google Cloud Translation (characters per month).
  static const int freeTierLimit = 500000;

  /// Price per million characters for translation.
  static const double pricePerMillion = 20.00;

  /// URL for Google Cloud Translation pricing details.
  static const String pricingUrl =
      "https://cloud.google.com/translate/pricing#basic-pricing";

  /// Estimates the translation cost based on an ARB file and target languages.
  ///
  /// - [arbFilePath]: Path to the ARB file to analyze.
  /// - [targetLanguages]: A list of target languages for translation.
  ///
  /// This method calculates:
  /// - Total characters in the ARB file (excluding metadata keys starting with `"@"`).
  /// - Characters already cached (if caching is enabled).
  /// - Remaining characters that require API calls.
  /// - Estimated translation cost based on **Google Cloud Translation pricing**.
  ///
  /// The results are printed to the console in a structured format.
  ///
  /// Example:
  /// ```dart
  /// final estimator = TranslationEstimator();
  /// estimator.estimateTranslationCost("lib/l10n/app_en.arb", ["es", "fr"]);
  /// ```
  void estimateTranslationCost(
      String arbFilePath, List<String> targetLanguages) {
    final file = File(arbFilePath);
    if (!file.existsSync()) {
      print("❌ Error: ARB file not found: $arbFilePath");
      return;
    }

    final config = TranslationConfig.instance; // Access shared configuration
    final Map<String, dynamic> arbData = jsonDecode(file.readAsStringSync());
    final String sourceLang = arbData["@@locale"] ?? "en";
    int totalCharacters = 0;
    int cachedCharacters = 0;

    // Calculate total and cached characters
    arbData.forEach((key, value) {
      if (!key.startsWith("@") && value is String) {
        final perKeyConfig = config.keyConfig[key] ?? {};
        final bool isIgnored = perKeyConfig['ignore'] ?? false;
        final bool noCache = perKeyConfig['no-cache'] ?? false;

        if (isIgnored) return;

        totalCharacters += value.length * targetLanguages.length;

        for (final targetLang in targetLanguages) {
          final cacheKey = TranslationUtils.generateCacheKey(
            fromLang: sourceLang,
            toLang: targetLang,
            text: value,
            key: key,
          );

          if (!noCache &&
              config.enableCache &&
              cacheManager.hasTranslation(cacheKey)) {
            cachedCharacters += value.length;
          }
        }
      }
    });

    // Calculate remaining characters and estimated cost
    final remainingCharacters = totalCharacters - cachedCharacters;
    final estimatedCost = (remainingCharacters / 1000000) * pricePerMillion;

    // Display the results
    print("\n📊 Translation Character Estimate:");
    print("-----------------------------------");
    print("🌍 Source ARB File: $arbFilePath");
    print("🔤 Source Language: $sourceLang");
    print("📌 Target Languages: ${targetLanguages.join(', ')}");
    print(
        "🔤 Total Characters (Before Cache): ${formatNumber(totalCharacters)}");
    print("💾 Cached Characters: ${formatNumber(cachedCharacters)}");
    print(
        "⚡ API Call Needed for: ${formatNumber(remainingCharacters)} characters");
    print("💰 Estimated Total Cost: \$${estimatedCost.toStringAsFixed(2)}");
    print(
        "ℹ️  Free Tier: First ${formatNumber(freeTierLimit)} characters per month are free.");
    print("🔗 More details on pricing: $pricingUrl");
    print("🚧 Note: This is an estimate. Actual cost depends on API usage.");
    print("------------------------------------------------\n");
  }

  /// Formats numbers with commas for better readability.
  ///
  /// Example:
  /// ```dart
  /// print(TranslationEstimator.formatNumber(1000000)); // Output: "1,000,000"
  /// ```
  static String formatNumber(int number) {
    return number
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",");
  }
}
