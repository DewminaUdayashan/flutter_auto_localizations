import 'dart:convert';
import 'dart:io';

class CacheManager {
  final String cacheFilePath;
  final bool enableCache;
  final Map<String, String> _cache = {};

  CacheManager({
    this.cacheFilePath = 'translation_cache.json',
    required this.enableCache,
  }) {
    if (enableCache) _loadCache();
  }

  /// ✅ Load existing translations only if caching is enabled
  void _loadCache() {
    if (!enableCache) return;
    final file = File(cacheFilePath);
    if (file.existsSync()) {
      try {
        final content = file.readAsStringSync();
        _cache.addAll(Map<String, String>.from(json.decode(content)));
      } catch (e) {
        print("🚧 Warning: Failed to load cache: $e");
      }
    }
  }

  /// ✅ Save updated cache only if caching is enabled
  void _saveCache() {
    if (enableCache) {
      File(cacheFilePath).writeAsStringSync(json.encode(_cache));
    }
  }

  /// ✅ Check if caching is enabled before returning a cached translation
  bool hasTranslation(String key) => enableCache && _cache.containsKey(key);

  /// ✅ Get translation from cache
  String? getTranslation(String key) => _cache[key];

  /// ✅ Store translation in cache and save to file
  void saveTranslation(String key, String value) {
    if (enableCache) {
      _cache[key] = value;
      _saveCache();
    }
  }

  /// ✅ Clear cache file if caching is enabled
  void clearCache() {
    if (enableCache) {
      _cache.clear();
      File(cacheFilePath).deleteSync();
    }
  }
}
