import 'dart:io';

import 'package:flutter_auto_localizations/src/file_manager.dart';
import 'package:test/test.dart';

void main() {
  group('FileManager', () {
    test('Reads and writes ARB files correctly, updating @@locale', () {
      final testFile = 'test/test_app.arb';
      final testData = {"@@locale": "en", "simpleText": "Hello World"};

      // Write test ARB file
      FileManager.writeArbFile(
          testFile, testData, "es"); // Target language: Spanish

      // Read back and validate
      final loadedData = FileManager.readArbFile(testFile);

      expect(loadedData["@@locale"],
          equals("es")); // ✅ Locale should update to "es"
      expect(loadedData["simpleText"],
          equals("Hello World")); // ✅ Data should remain unchanged

      File(testFile).deleteSync(); // Cleanup
    });
  });
}
