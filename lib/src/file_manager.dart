import 'dart:convert';
import 'dart:io';

/// A utility class for handling ARB (Application Resource Bundle) files.
///
/// The `FileManager` provides methods for reading and writing ARB files, which
/// are commonly used for managing localization strings in Flutter applications.
///
/// Example usage:
/// ```dart
/// final data = FileManager.readArbFile("lib/l10n/app_en.arb");
/// FileManager.writeArbFile("lib/l10n/app_es.arb", data, "es");
/// ```
class FileManager {
  /// Reads an ARB file from the specified [path] and returns its content as a `Map<String, dynamic>`.
  ///
  /// Throws an [Exception] if the file does not exist.
  ///
  /// Example:
  /// ```dart
  /// final data = FileManager.readArbFile("lib/l10n/app_en.arb");
  /// print(data["title"]); // Output: "Hello"
  /// ```
  static Map<String, dynamic> readArbFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("Localization file not found: $path");
    }
    return json.decode(file.readAsStringSync());
  }

  /// Writes the given [data] to an ARB file at the specified [path].
  ///
  /// The [targetLocale] parameter updates the `"@@locale"` key in the ARB file to
  /// ensure the locale is correctly set.
  ///
  /// Example:
  /// ```dart
  /// final data = {"title": "Hola", "@@locale": "en"};
  /// FileManager.writeArbFile("lib/l10n/app_es.arb", data, "es");
  /// ```
  ///
  /// - If `"@@locale"` exists in the data, it is updated to match [targetLocale].
  /// - The JSON output is formatted with an indentation of 2 spaces for readability.
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
