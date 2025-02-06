import 'dart:io';

import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';

void main() async {
  const configPath = "translation_config.json";
  const localizationDir = "lib/l10n/";

  try {
    final config = ConfigParser.loadConfig(configPath);
    final defaultLang = config["default"];
    final targetLanguages = List<String>.from(config["languages"]);

    final arbFile = "$localizationDir/app_$defaultLang.arb";
    final data = FileManager.readArbFile(arbFile);

    final apiKey = Platform.environment['GOOGLE_TRANSLATE_API_KEY'];
    if (apiKey == null) {
      print("Missing GOOGLE_TRANSLATE_API_KEY environment variable.");
      exit(1);
    }

    final translator = Translator(apiKey);

    for (final lang in targetLanguages) {
      print("Translating to $lang...");
      final newData = Map<String, dynamic>.from(data);

      for (final key in data.keys) {
        if (key.startsWith('@')) continue;
        newData[key] =
            await translator.translateText(data[key], defaultLang, lang);
      }

      final newFile = "$localizationDir/app_$lang.arb";
      FileManager.writeArbFile(newFile, newData);
      print("✅ Translated file saved: $newFile");
    }

    print("🎉 Translation completed successfully!");
  } catch (e) {
    print("❌ Error: $e");
  }
}
