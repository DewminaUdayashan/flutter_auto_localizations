import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter_auto_localizations/flutter_auto_localizations.dart';
import 'package:flutter_auto_localizations/src/shared/translation_config.dart';

void main() async {
  try {
    // ✅ Initialize configuration
    final config = await _initializeTranslationConfig();

    final localizationDir = config["localizationDir"];
    final templateArbFile = config["templateArbFile"];
    final defaultLang = config["defaultLang"];
    final targetLanguages = config["targetLanguages"];
    final shouldRunPubGet = config["shouldRunPubGet"];
    final apiKey = config["apiKey"];
    final arbFile = "$localizationDir/$templateArbFile";
    if (!File(arbFile).existsSync()) {
      print("❌ Error: Source ARB file not found: $arbFile");
      exit(1);
    }

    final data = FileManager.readArbFile(arbFile);

    if (apiKey == null) {
      print("❌ Missing GOOGLE_TRANSLATE_API_KEY environment variable.");
      exit(1);
    }

    // ✅ Estimate translation cost before starting
    final estimator = TranslationEstimator();
    estimator.estimateTranslationCost(arbFile, targetLanguages);

    // ✅ Ask for confirmation before proceeding
    stdout.write("\n🔄 Proceed with translation? (yes/no): ");
    final userInput = stdin.readLineSync()?.trim().toLowerCase();

    if (userInput != "yes") {
      print("❌ Translation cancelled.");
      exit(0);
    }

    final translator = Translator(apiKey);

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

Future<Map<String, dynamic>> _initializeTranslationConfig() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final config = ConfigParser.loadConfig();

  final localizationDir = config["localization-dir"];
  final templateArbFile = config["template-arb-file"];
  final defaultLang = config["default-lang"];
  final targetLanguages = List<String>.from(config["languages"]);
  final shouldRunPubGet =
      config.containsKey("run-pub-get") ? config["run-pub-get"] : true;
  final globalIgnorePhrases =
      List<String>.from(config["global-ignore-phrases"]);
  final keyConfig = Map<String, dynamic>.from(config["key-config"]);
  final enableCache = config['enable-cache'] as bool;

  // ✅ Explicitly initialize TranslationConfig
  TranslationConfig.initialize(
    keyConfig: keyConfig,
    globalIgnorePhrases: globalIgnorePhrases,
    enableCache: enableCache,
  );

  final apiKey = env['GOOGLE_TRANSLATE_API_KEY'] ??
      Platform.environment['GOOGLE_TRANSLATE_API_KEY'];

  if (apiKey == null) {
    throw Exception("❌ Missing GOOGLE_TRANSLATE_API_KEY environment variable.");
  }

  return {
    "localizationDir": localizationDir,
    "templateArbFile": templateArbFile,
    "defaultLang": defaultLang,
    "targetLanguages": targetLanguages,
    "shouldRunPubGet": shouldRunPubGet,
    "apiKey": apiKey,
  };
}
