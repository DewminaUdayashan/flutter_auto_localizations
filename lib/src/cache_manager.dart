import 'dart:convert';
import 'dart:io';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();

  factory CacheManager({
    String cacheFilePath = '.cache/translation_cache.json', // ✅ Updated path
    bool enableCache = true,
  }) {
    _instance._cacheFilePath = cacheFilePath;
    _instance._enableCache = enableCache;
    _instance._ensureCacheDirectoryExists(); // ✅ Ensure the directory exists
    if (enableCache) _instance._loadCache();
    _instance._addToGitIgnore(); // ✅ Auto-add to .gitignore
    return _instance;
  }

  CacheManager._internal(); // Private constructor

  late String _cacheFilePath;
  late bool _enableCache;
  final Map<String, String> _cache = {};

  /// ✅ Ensure the `.cache/` directory exists
  void _ensureCacheDirectoryExists() {
    final directory = Directory('.cache');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }

  /// ✅ Auto-add cache file to `.gitignore` if not already ignored
  void _addToGitIgnore() {
    const gitIgnoreFile = '.gitignore';
    final cacheEntry = '.cache/translation_cache.json';

    final gitIgnore = File(gitIgnoreFile);
    if (gitIgnore.existsSync()) {
      final lines = gitIgnore.readAsLinesSync();
      if (!lines.contains(cacheEntry)) {
        gitIgnore.writeAsStringSync('\n$cacheEntry', mode: FileMode.append);
        print("✅ Added `$cacheEntry` to `.gitignore`.");
      }
    }
  }

  /// ✅ Load existing translations only if caching is enabled
  void _loadCache() {
    if (!_enableCache) return;
    final file = File(_cacheFilePath);
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
    if (_enableCache) {
      File(_cacheFilePath).writeAsStringSync(json.encode(_cache));
    }
  }

  /// ✅ Check if caching is enabled before returning a cached translation
  bool hasTranslation(String key) => _enableCache && _cache.containsKey(key);

  /// ✅ Get translation from cache
  String? getTranslation(String key) => _cache[key];

  /// ✅ Store translation in cache and save to file
  void saveTranslation(String key, String value) {
    if (_enableCache) {
      _cache[key] = value;
      _saveCache();
    }
  }

  /// ✅ Clear cache file if caching is enabled
  void clearCache() {
    if (_enableCache) {
      _cache.clear();
      File(_cacheFilePath).deleteSync();
    }
  }
}
