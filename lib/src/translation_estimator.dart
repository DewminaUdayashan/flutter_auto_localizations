import 'dart:convert';
import 'dart:io';

import 'package:flutter_auto_localizations/src/shared/utils.dart';

import 'cache_manager.dart';

class TranslationEstimator {
  TranslationEstimator({
    CacheManager? cacheManager,
  }) : cacheManager = cacheManager ??
            CacheManager(enableCache: TranslationConfig.instance.enableCache);

  final CacheManager cacheManager;

  static const int freeTierLimit = 500000;
  static const double pricePerMillion = 20.00;
  static const String pricingUrl =
      "https://cloud.google.com/translate/pricing#basic-pricing";

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

    final remainingCharacters = totalCharacters - cachedCharacters;
    final estimatedCost = (remainingCharacters / 1000000) * pricePerMillion;

    print("\n📊 Translation Character Estimate:");
    print("-----------------------------------");
    print("🌍 Source ARB File: $arbFilePath");
    print("🔤 Source Language: $sourceLang");
    print("📌 Target Languages: ${targetLanguages.join(', ')}");
    print("🔤 Total Characters (Before Cache): $totalCharacters");
    print("💾 Cached Characters: $cachedCharacters");
    print("⚡ API Call Needed for: $remainingCharacters characters");
    print("💰 Estimated Total Cost: \$${estimatedCost.toStringAsFixed(2)}");
    print("ℹ️  Free Tier: First $freeTierLimit characters per month are free.");
    print("🔗 More details on pricing: $pricingUrl");
    print("🚧 Note: This is an estimate. Actual cost depends on API usage.");
    print("------------------------------------------------\n");
  }
}
