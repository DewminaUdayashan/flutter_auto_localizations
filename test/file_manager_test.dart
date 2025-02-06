import 'dart:io';

import 'package:flutter_auto_localizations/src/file_manager.dart';
import 'package:test/test.dart';

void main() {
  group('FileManager', () {
    test('Reads and writes ARB files correctly', () {
      final testFile = 'test/test_app.arb';
      final testData = {'hello': 'Hello', 'welcome': 'Welcome'};

      FileManager.writeArbFile(testFile, testData);
      final loadedData = FileManager.readArbFile(testFile);

      expect(loadedData['hello'], 'Hello');
      expect(loadedData['welcome'], 'Welcome');

      File(testFile).deleteSync(); // Cleanup
    });
  });
}
