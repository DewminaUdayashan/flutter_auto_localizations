import 'dart:convert';
import 'dart:io';

class CacheManager {
  final String cacheFilePath;
  final Map<String, String> _cache = {};

  CacheManager({this.cacheFilePath = 'translation_cache.json'}) {
    _loadCache();
  }

  /// ✅ Load existing translations from cache file
  void _loadCache() {
    final file = File(cacheFilePath);
    if (file.existsSync()) {
      try {
        final content = file.readAsStringSync();
        _cache.addAll(Map<String, String>.from(json.decode(content)));
      } catch (e) {
        print("⚠️ Warning: Failed to load cache: $e");
      }
    }
  }

  /// ✅ Save updated cache back to file
  void _saveCache() {
    File(cacheFilePath).writeAsStringSync(json.encode(_cache));
  }

  /// ✅ Check if translation exists in cache
  bool hasTranslation(String key) => _cache.containsKey(key);

  /// ✅ Get translation from cache
  String? getTranslation(String key) => _cache[key];

  /// ✅ Store translation in cache and save to file
  void saveTranslation(String key, String value) {
    _cache[key] = value;
    _saveCache();
  }

  /// ✅ Clear all cached translations
  void clearCache() {
    _cache.clear();
    File(cacheFilePath).deleteSync();
  }
}
