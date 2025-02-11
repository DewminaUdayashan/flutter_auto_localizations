import 'dart:convert';
import 'dart:io';

import 'cache_manager.dart';

class TranslationEstimator {
  TranslationEstimator({
    CacheManager? cacheManager,
    required this.isCachingEnabled,
  }) : cacheManager =
            cacheManager ?? CacheManager(enableCache: isCachingEnabled);

  final CacheManager cacheManager;
  final bool isCachingEnabled;

  static const int freeTierLimit =
      500000; // Free for first 500K characters (per month)
  static const double pricePerMillion = 20.00; // $20 per million characters
  static const String pricingUrl =
      "https://cloud.google.com/translate/pricing#basic-pricing"; // Google Pricing Page

  void estimateTranslationCost(
    String arbFilePath,
    List<String> targetLanguages,
  ) {
    final file = File(arbFilePath);
    if (!file.existsSync()) {
      print("❌ Error: ARB file not found: $arbFilePath");
      return;
    }

    final Map<String, dynamic> arbData = jsonDecode(file.readAsStringSync());
    final String sourceLang =
        arbData["@@locale"] ?? "en"; // Default source language
    int totalCharacters = 0;
    int cachedCharacters = 0;

    // ✅ Iterate through each key-value pair in the ARB file
    arbData.forEach((key, value) {
      if (!key.startsWith("@") && value is String) {
        totalCharacters += value.length * targetLanguages.length;

        // ✅ Check cache for each target language
        for (final targetLang in targetLanguages) {
          final cacheKey = "$sourceLang-$targetLang-$value";
          if (isCachingEnabled && cacheManager.hasTranslation(cacheKey)) {
            cachedCharacters += value.length;
          }
        }
      }
    });

    // ✅ Adjust total characters based on cache
    final remainingCharacters = totalCharacters - cachedCharacters;

    // ✅ Calculate estimated cost after using cache
    final estimatedCost = (remainingCharacters / 1000000) * pricePerMillion;

    // 📊 Display Output
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
        "ℹ️ Free Tier: First ${formatNumber(freeTierLimit)} characters per month are free, if applicable.");
    print("🔗 More details on pricing: $pricingUrl");
    print("🚧 Note: This is an estimate. Actual cost depends on API usage.");
    print("------------------------------------------------\n");
  }

  /// ✅ Formats numbers with commas for better readability
  static String formatNumber(int number) {
    return number
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",");
  }
}
