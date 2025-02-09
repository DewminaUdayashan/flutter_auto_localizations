import 'dart:convert';
import 'dart:io';

class TranslationEstimator {
  static const int freeTierLimit = 500000; // Free for first 500K characters (per month)
  static const double pricePerMillion = 20.00; // $20 per million characters
  static const String pricingUrl = "https://cloud.google.com/translate/pricing#basic-pricing"; // Google Pricing Page

  static void estimateTranslationCost(String arbFilePath, List<String> targetLanguages) {
    final file = File(arbFilePath);
    if (!file.existsSync()) {
      print("❌ Error: ARB file not found: $arbFilePath");
      return;
    }

    final Map<String, dynamic> arbData = jsonDecode(file.readAsStringSync());
    int totalCharacters = 0;

    // Count translatable characters (ignore keys and metadata)
    arbData.forEach((key, value) {
      if (!key.startsWith("@") && value is String) {
        totalCharacters += value.length;
      }
    });

    // Calculate estimated total translated characters
    final estimatedTranslatedCharacters = totalCharacters * targetLanguages.length;

    // ✅ Calculate estimated cost for ALL characters (no free tier subtraction)
    final estimatedCost = (estimatedTranslatedCharacters / 1_000_000) * pricePerMillion;

    // Display output
    print("\n📊 Translation Character Estimate:");
    print("-----------------------------------");
    print("🌍 Source ARB File: $arbFilePath");
    print("🔤 Estimated Total Characters: ${formatNumber(totalCharacters)}");
    print("📌 Target Languages: ${targetLanguages.join(', ')}");
    print("🔣 Total Estimated Translated Characters: ${formatNumber(estimatedTranslatedCharacters)}");

    print("💰 Estimated Total Cost: \$${estimatedCost.toStringAsFixed(2)}");

    print("ℹ️ Free Tier: First ${formatNumber(freeTierLimit)} characters per month are free, if applicable.");
    print("🔗 More details on pricing: $pricingUrl");
    print("🚧 Note: This is an estimate. Actual cost depends on API usage.");
    print("------------------------------------------------\n");
  }

  /// ✅ Formats numbers with commas for better readability
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",");
  }
}