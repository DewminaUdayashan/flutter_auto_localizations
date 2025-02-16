/// Configuration manager for translation settings.
///
/// This singleton class provides a way to configure translation-related
/// settings such as key mappings, ignored phrases, and caching behavior.
///
/// Example usage:
/// ```dart
/// TranslationConfig.initialize(
///   keyConfig: {'hello': 'Hola'},
///   globalIgnorePhrases: ['test'],
///   enableCache: true,
/// );
///
/// var config = TranslationConfig.instance;
/// print(config.keyConfig); // {'hello': 'Hola'}
/// ```
class TranslationConfig {
  /// Private constructor for initializing the [TranslationConfig] singleton.
  ///
  /// Use [initialize] to create an instance before accessing [instance].
  TranslationConfig._internal({
    required this.keyConfig,
    required this.globalIgnorePhrases,
    required this.enableCache,
  });

  /// The singleton instance of [TranslationConfig].
  static TranslationConfig? _instance;

  /// Initializes the [TranslationConfig] singleton.
  ///
  /// This method must be called **before** accessing [instance], otherwise
  /// an exception will be thrown.
  ///
  /// - [keyConfig]: A map of translation keys and their corresponding values.
  /// - [globalIgnorePhrases]: A list of phrases that should be ignored during translation.
  /// - [enableCache]: Enables or disables caching for translations.
  ///
  /// Example:
  /// ```dart
  /// TranslationConfig.initialize(
  ///   keyConfig: {'greeting': 'Hello'},
  ///   globalIgnorePhrases: ['example'],
  ///   enableCache: true,
  /// );
  /// ```
  static void initialize({
    required Map<String, dynamic> keyConfig,
    required List<String> globalIgnorePhrases,
    required bool enableCache,
  }) {
    _instance ??= TranslationConfig._internal(
      keyConfig: keyConfig,
      globalIgnorePhrases: globalIgnorePhrases,
      enableCache: enableCache,
    );
  }

  /// Returns the singleton instance of [TranslationConfig].
  ///
  /// Throws an exception if [initialize] has not been called first.
  ///
  /// Example:
  /// ```dart
  /// var config = TranslationConfig.instance;
  /// ```
  static TranslationConfig get instance {
    if (_instance == null) {
      throw Exception(
          "❌ TranslationConfig is not initialized. Call TranslationConfig.initialize() first.");
    }
    return _instance!;
  }

  /// A map containing translation key-value pairs.
  ///
  /// Example:
  /// ```dart
  /// var config = TranslationConfig.instance;
  /// print(config.keyConfig); // {'hello': 'Hola'}
  /// ```
  final Map<String, dynamic> keyConfig;

  /// A list of phrases that should be ignored during translation.
  ///
  /// Example:
  /// ```dart
  /// var config = TranslationConfig.instance;
  /// print(config.globalIgnorePhrases); // ['test', 'sample']
  /// ```
  final List<String> globalIgnorePhrases;

  /// Whether caching is enabled for translations.
  ///
  /// If `true`, previously translated values may be cached for better performance.
  ///
  /// Example:
  /// ```dart
  /// var config = TranslationConfig.instance;
  /// print(config.enableCache); // true
  /// ```
  final bool enableCache;
}
