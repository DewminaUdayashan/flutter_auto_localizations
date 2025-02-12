class TranslationConfig {
  static TranslationConfig? _instance;

  // Private constructor
  TranslationConfig._internal({
    required this.keyConfig,
    required this.globalIgnorePhrases,
    required this.enableCache,
  });

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

  // Public getter to access the shared instance
  static TranslationConfig get instance {
    if (_instance == null) {
      throw Exception(
          "❌ TranslationConfig is not initialized. Call TranslationConfig.initialize() first.");
    }
    return _instance!;
  }

  final Map<String, dynamic> keyConfig;
  final List<String> globalIgnorePhrases;
  final bool enableCache;
}
