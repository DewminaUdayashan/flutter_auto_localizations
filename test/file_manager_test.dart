import 'dart:convert';
import 'dart:io';

import 'package:flutter_auto_localizations/src/file_manager.dart';
import 'package:test/test.dart';

void main() {
  group('FileManager Tests', () {
    test('✅ Reads ARB file correctly', () {
      final testFile = File("test.arb")
        ..writeAsStringSync(jsonEncode({"hello": "world"}));
      final data = FileManager.readArbFile("test.arb");

      expect(data, contains("hello"));
      expect(data["hello"], equals("world"));

      testFile.deleteSync(); // Cleanup
    });

    test('✅ Handles missing file error', () {
      expect(() => FileManager.readArbFile("missing.arb"),
          throwsA(isA<Exception>()));
    });

    test('✅ Writes ARB file correctly', () {
      final testFile = "test_write.arb";
      FileManager.writeArbFile(testFile, {"greeting": "Hello"}, "en");

      final writtenData = jsonDecode(File(testFile).readAsStringSync());
      expect(writtenData, contains("greeting"));
      expect(writtenData["greeting"], equals("Hello"));

      File(testFile).deleteSync(); // Cleanup
    });
  });
}
