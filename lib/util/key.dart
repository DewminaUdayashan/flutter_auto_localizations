import 'dart:io';

String? _getApiKeyFromEnvFile() {
  final envFile = File('.env');

  if (!envFile.existsSync()) {
    print(
        "⚠️ Warning: .env file not found. Falling back to environment variables.");
    return null;
  }

  final lines = envFile.readAsLinesSync();
  for (final line in lines) {
    if (line.startsWith('GOOGLE_TRANSLATE_API_KEY=')) {
      return line.split('=')[1].trim(); // Extract the API key
    }
  }

  print("⚠️ Warning: GOOGLE_TRANSLATE_API_KEY not found in .env file.");
  return null;
}

String? _getApiKeyFromPlatform() =>
    Platform.environment['GOOGLE_TRANSLATE_API_KEY'];

// Get API key from .env file or fallback to environment variables
String? getApiKey() => _getApiKeyFromEnvFile() ?? _getApiKeyFromPlatform();
