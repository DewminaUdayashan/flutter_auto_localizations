import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';

void main() async {
  try {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final config = ConfigParser.loadConfig();

    // Extract dynamic localization settings
    final localizationDir = config["localization_dir"];
    final templateArbFile = config["template_arb_file"];
    final defaultLang = config["default_lang"];

    final targetLanguages = List<String>.from(config["languages"]);
    final shouldRunPubGet =
        config.containsKey("run_pub_get") ? config["run_pub_get"] : true;
    final globalIgnorePhrases =
        List<String>.from(config["global_ignore_phrases"]);
    final keyConfig = Map<String, dynamic>.from(config["key_config"]);

    final arbFile = "$localizationDir/$templateArbFile";
    if (!File(arbFile).existsSync()) {
      print("❌ Error: Source ARB file not found: $arbFile");
      exit(1);
    }

    final data = FileManager.readArbFile(arbFile);
    final apiKey = env['GOOGLE_TRANSLATE_API_KEY'] ??
        Platform.environment['GOOGLE_TRANSLATE_API_KEY'];

    if (apiKey == null) {
      print("❌ Missing GOOGLE_TRANSLATE_API_KEY environment variable.");
      exit(1);
    }

    // ✅ Estimate translation cost before starting
    TranslationEstimator.estimateTranslationCost(arbFile, targetLanguages);

    // ✅ Ask for confirmation before proceeding
    stdout.write("\n🔄 Proceed with translation? (yes/no): ");
    final userInput = stdin.readLineSync()?.trim().toLowerCase();

    if (userInput != "yes") {
      print("❌ Translation cancelled.");
      exit(0);
    }

    final translator = Translator(
      apiKey,
      globalIgnorePhrases: globalIgnorePhrases,
      keyConfig: keyConfig,
    );

    for (final lang in targetLanguages) {
      print("\n🌍 Translating to $lang...");

      final newData = Map<String, dynamic>.from(data);
      final totalEntries =
          data.keys.where((key) => !key.startsWith('@')).length;
      int currentProgress = 0;

      for (final key in data.keys) {
        if (key.startsWith('@')) continue;

        currentProgress++;
        stdout.write("\r📌 Progress: $currentProgress / $totalEntries");

        newData[key] =
            await translator.translateText(key, data[key], defaultLang, lang);
      }

      final newFile = "$localizationDir/app_$lang.arb";
      FileManager.writeArbFile(newFile, newData, lang);
      print("\n✅ Translated file saved: $newFile");
    }

    if (shouldRunPubGet) {
      print("\n📦 Running 'flutter pub get'...");
      Process.runSync("flutter", ["pub", "get"]);
      print("✅ 'flutter pub get' completed.");
    }

    print("\n🎉 Translation completed successfully!");
    exit(0);
  } catch (e) {
    print("❌ Error: $e");
  }
}
