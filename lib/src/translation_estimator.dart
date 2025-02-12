import 'dart:convert';
import 'dart:io';

import 'cache_manager.dart';

class TranslationEstimator {
  TranslationEstimator({
    required this.isCachingEnabled,
    required this.keyConfig,
    CacheManager? cacheManager,
  }) : cacheManager =
            cacheManager ?? CacheManager(enableCache: isCachingEnabled);

  final CacheManager cacheManager;
  final bool isCachingEnabled;
  final Map<String, dynamic> keyConfig;

  static const int freeTierLimit =
      500000; // Free for first 500K characters (per month)
  static const double pricePerMillion = 20.00; // $20 per million characters
  static const String pricingUrl =
      "https://cloud.google.com/translate/pricing#basic-pricing";

  void estimateTranslationCost(
      String arbFilePath, List<String> targetLanguages) {
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

    arbData.forEach((key, value) {
      if (!key.startsWith("@") && value is String) {
        final perKeyConfig = keyConfig[key] ?? {};
        final bool isIgnored = perKeyConfig['ignore'] ?? false;
        final bool noCache = perKeyConfig['no-cache'] ?? false;

        if (isIgnored) return; // ✅ Skip translation if `ignore` is true

        totalCharacters += value.length * targetLanguages.length;

        for (final targetLang in targetLanguages) {
          final cacheKey = "$sourceLang-$targetLang-$value";

          if (!noCache &&
              isCachingEnabled &&
              cacheManager.hasTranslation(cacheKey)) {
            cachedCharacters += value.length;
          }
        }
      }
    });

    final remainingCharacters = totalCharacters - cachedCharacters;
    final estimatedCost = (remainingCharacters / 1000000) * pricePerMillion;

    // 📊 Display Output
    print("\n📊 Translation Character Estimate:");
    print("-----------------------------------");
    print("🌍 Source ARB File: $arbFilePath");
    print("🔤 Source Language: $sourceLang");
    print("📌 Target Languages: ${targetLanguages.join(', ')}");
    print("🔤 Total Characters (Before Cache): $totalCharacters");
    print("💾 Cached Characters: $cachedCharacters");
    print("⚡ API Call Needed for: $remainingCharacters characters");
    print("💰 Estimated Total Cost: \$${estimatedCost.toStringAsFixed(2)}");
    print("ℹ️ Free Tier: First $freeTierLimit characters per month are free.");
    print("🔗 More details on pricing: $pricingUrl");
    print("🚧 Note: This is an estimate. Actual cost depends on API usage.");
    print("------------------------------------------------\n");
  }
}
