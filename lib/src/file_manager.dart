import 'dart:convert';
import 'dart:io';

class FileManager {
  static Map<String, dynamic> readArbFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("Localization file not found: $path");
    }
    return json.decode(file.readAsStringSync());
  }

  static void writeArbFile(
    String path,
    Map<String, dynamic> data,
    String targetLocale,
  ) {
    final file = File(path);

    // ✅ Update @@locale to match the target language code
    if (data.containsKey("@@locale")) {
      data["@@locale"] = targetLocale;
    }

    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(data));
  }
}
