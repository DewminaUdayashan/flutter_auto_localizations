import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';

void main() async {
  const localizationDir = "lib/l10n/";

  try {
    final env = DotEnv(includePlatformEnvironment: true)..load();

    final config = ConfigParser.loadConfig();
    final defaultLang = config["default"];
    final targetLanguages = List<String>.from(config["languages"]);
    final shouldRunPubGet =
        config.containsKey("run_pub_get") ? config["run_pub_get"] : true;

    final arbFile = "$localizationDir/app_$defaultLang.arb";
    final data = FileManager.readArbFile(arbFile);

    final apiKey = env['GOOGLE_TRANSLATE_API_KEY'];

    if (apiKey == null) {
      print("❌ Missing GOOGLE_TRANSLATE_API_KEY environment variable.");
      exit(1);
    }

    final translator = Translator(apiKey);

    for (final lang in targetLanguages) {
      print("\n🌍 Translating to $lang...");

      final newData = Map<String, dynamic>.from(data);
      final totalEntries =
          data.keys.where((key) => !key.startsWith('@')).length;
      int currentProgress = 0;

      for (final key in data.keys) {
        if (key.startsWith('@')) continue; // Skip metadata keys

        // Show progress
        currentProgress++;
        stdout.write("\r📌 Progress: $currentProgress / $totalEntries");

        newData[key] =
            await translator.translateText(data[key], defaultLang, lang);
      }

      final newFile = "$localizationDir/app_$lang.arb";
      FileManager.writeArbFile(newFile, newData);
      print("\n✅ Translated file saved: $newFile");
    }

    if (shouldRunPubGet) {
      print("\n📦 Running 'flutter pub get'...");
      Process.runSync("flutter", ["pub", "get"]);
      print("✅ 'flutter pub get' completed.");
    }

    print("\n🎉 Translation completed successfully!");
  } catch (e) {
    print("❌ Error: $e");
  }
}
