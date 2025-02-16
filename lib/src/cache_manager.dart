import 'dart:convert';
import 'dart:io';

/// A singleton class for managing cached translations.
///
/// The `CacheManager` stores translations in a JSON file for quick retrieval,
/// reducing redundant processing and API calls. The cache file is automatically
/// created inside a `.cache/` directory, and the path can be customized.
///
/// Example usage:
/// ```dart
/// final cacheManager = CacheManager();
/// cacheManager.saveTranslation("hello", "Hola");
/// print(cacheManager.getTranslation("hello")); // Outputs: Hola
/// ```
class CacheManager {
  /// Creates a new instance of `CacheManager` with optional parameters.
  ///
  /// - [cacheFilePath]: The file path where the cache is stored (default: `.cache/translation_cache.json`).
  /// - [enableCache]: Enables or disables caching (default: `true`).
  ///
  /// If caching is enabled, it automatically:
  /// - Loads previously saved translations.
  /// - Ensures the `.cache/` directory exists.
  /// - Adds the cache file to `.gitignore` if not already ignored.
  factory CacheManager({
    String cacheFilePath = '.cache/translation_cache.json',
    bool enableCache = true,
  }) {
    _instance._cacheFilePath = cacheFilePath;
    _instance._enableCache = enableCache;
    _instance._ensureCacheDirectoryExists(); // Ensure directory exists
    if (enableCache) _instance._loadCache();
    _instance._addToGitIgnore(); // Auto-add to .gitignore
    return _instance;
  }

  /// Private constructor for the singleton pattern.
  CacheManager._internal();

  /// The singleton instance of `CacheManager`.
  static final CacheManager _instance = CacheManager._internal();

  /// The file path where translations are cached.
  late String _cacheFilePath;

  /// Whether caching is enabled or not.
  late bool _enableCache;

  /// A map that stores cached translations.
  final Map<String, String> _cache = {};

  /// Ensures that the `.cache/` directory exists.
  ///
  /// If the directory does not exist, it creates it.
  void _ensureCacheDirectoryExists() {
    final directory = Directory('.cache');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }

  /// Adds the cache file to `.gitignore` to prevent it from being committed.
  ///
  /// If `.gitignore` exists and does not already contain `.cache/translation_cache.json`,
  /// it appends the entry to the file.
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

  /// Loads existing translations from the cache file.
  ///
  /// Reads the JSON file and populates the `_cache` map with stored translations.
  /// If the file does not exist or cannot be read, it logs a warning.
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

  /// Saves the current cache state to a file.
  ///
  /// If caching is enabled, it writes the `_cache` map as a JSON string to the cache file.
  void _saveCache() {
    if (_enableCache) {
      File(_cacheFilePath).writeAsStringSync(json.encode(_cache));
    }
  }

  /// Checks if a translation for a given [key] exists in the cache.
  ///
  /// Returns `true` if the key exists and caching is enabled, otherwise `false`.
  bool hasTranslation(String key) => _enableCache && _cache.containsKey(key);

  /// Retrieves a translation for a given [key] from the cache.
  ///
  /// Returns the translation string if found, otherwise `null`.
  String? getTranslation(String key) => _cache[key];

  /// Stores a new translation in the cache and saves it to the file.
  ///
  /// - [key]: The translation key.
  /// - [value]: The translated text.
  ///
  /// If caching is enabled, the translation is added to `_cache` and saved to disk.
  void saveTranslation(String key, String value) {
    if (_enableCache) {
      _cache[key] = value;
      _saveCache();
    }
  }

  /// Clears all cached translations and deletes the cache file.
  ///
  /// If caching is enabled, this method removes all stored translations and
  /// deletes the cache file from disk.
  void clearCache() {
    if (_enableCache) {
      _cache.clear();
      File(_cacheFilePath).deleteSync();
    }
  }
}
