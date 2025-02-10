
Effortlessly automate the localization process in your Flutter applications with Flutter Auto Localizations. This CLI tool streamlines the integration of internationalization (i18n) by parsing ARB files and generating the necessary localization code, ensuring a seamless multilingual user experience.

## ✨ Features

✅ Fully compatible with  **flutter_localizations**
✅  **Automatic parsing of ARB files**  and localization for specified languages
✅  **Generates localization delegates**  and localized string accessors
✅ **Supports ICU Plural and Select messages** for advanced translations
✅ **Customizable configurations** via l10n.yaml
✅  **Seamless integration**  with existing Flutter projects
✅  **Estimates API costs**  for translation requests

## 📦 Installation

### 1. Enable Flutter Localizations

Add the following to your  pubspec.yaml  under  **dependencies**  if not already present:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

Enable code generation by adding this under  **flutter**:

```yaml
flutter:
  generate: true
```

### 2. Add the package

Add the following under  **dev_dependencies**  in  pubspec.yaml:

```yaml
dev_dependencies:
  flutter_auto_localizations: ^1.0.0
```

Then, run:

```bash
flutter pub get
```

## ⚙️ Configuration

### 1. Configure l10n.yaml

Create a  **l10n.yaml**  file in the root of your project and define your localization settings:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart

languages:
  - en
  - es
  - fr
```

##### 🔹 Find supported translation languages [here](https://cloud.google.com/translate/docs/languages).

### 2. Set Up Google Cloud Translation API

To enable automatic translations, follow these steps:

#### 🔑 Create an API Key & Configure Google Cloud Console

•  Create an API key from  [**Google Cloud Console**](https://console.cloud.google.com/).
•  Enable  [**Cloud Translation API**](https://cloud.google.com/translate).
•  Billing must be enabled to use this API.

>💡 Google offers free translations for the first 500,000 characters per month (equivalent to $10 free credit monthly). After 500,000 characters, the cost is $20 per million characters.

> ⚠️  **Important:** These prices and quota might be changed over time. Always check the latest  [**pricing details**](https://cloud.google.com/translate/pricing#basic-pricing).

### 3. Store API Key Securely**

•  Create a  **.env**  file in your project’s root directory.
•  Add your API key like this:

```
GOOGLE_TRANSLATE_API_KEY=<put_your_api_key>
```
> ⚠️  **Important:**  Add  .env  to your  **.gitignore**  file to avoid exposing your API key in version control.

## 🚀 Usage

After configuration, generate localization files by running:

```bash
dart run flutter_auto_localizations
```

### 🛠️ Example Usage in Flutter

Once localization files are generated, use them in your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.title),
      ),
      body: Center(
        child: Text(localizations.welcomeMessage),
      ),
    );
  }
}
```

## 🛠 Configuration Options

Below is a detailed explanation of all possible configurations in the  l10n.yaml  file.

#### 🔹 arb-dir (Localization Directory)

```yaml
arb-dir: lib/l10n
```

Defines the  **directory**  where  .arb  (Application Resource Bundle) files are stored.

#### 🔹 template-arb-file (Default Language ARB File)

```yaml
template-arb-file: app_en.arb
```

Specifies the  **base ARB file**  used as a reference for translations.
📌 **Must be located inside the arb-dir directory.**
📌 The  **default language**  is inferred from this filename (app_en.arb  →  en).

#### 🔹 output-localization-file (Generated File)

```yaml
output-localization-file: app_localizations.dart
```

Defines the  **Dart file**  where the localization implementation will be generated.

#### 🔹 languages (Target Translation Languages)

```yaml
languages:
  - en
  - es
  - fr
```

A list of  **languages**  to be generated from the template ARB file.
📌 ARB file will be generated to each specified language.
📌  **Supported languages:**  See  [Google Cloud Translate Docs](https://cloud.google.com/translate/docs/languages)

### 🚀 Ignore Phrase Configurations

These settings help **control how translations handle specific words and phrases**.

#### 🔹 global_ignore_phrases (Globally Ignored Phrases)

```yaml
global_ignore_phrases:
  - "Technology"
  - "Notebook"
  - "Settings"
```

•  Defines **words/phrases that should never be translated**, **across all keys**.
•  Useful for **brand names, technical terms, or proper nouns**.
•  These phrases will **always remain in their original language**.

##### 📌 Example

If Technology is in global_ignore_phrases, then:
• **English:**  "Latest Technology"
• **Spanish Translation:**  "Última Technology" (**Technology remains unchanged!**)

#### 🔹 key_config (Per-Key Customization)

Defines  **per-key translation behavior**  by allowing you to  **override global settings**  or specify custom ignore phrases for individual translation keys.

To customize translations for a specific key,  **use the key name from your ARB file**  and define configurations under  key_config.

##### 📌 How it works

•  Each  **key in your ARB file**  can have its own configuration.
•  Use  **skipGlobalIgnore**  to bypass the global ignore list.
•  Use  **key_ignore_phrases**  to specify words that should not be translated for that key.

##### 📌 Example ARB File (app_en.arb)

```json
{
  "productDescription": "This is a premium service available worldwide.",
  "specialOffer": "This exclusive deal is available for a limited time!"
}
```

##### 📌 Corresponding l10n.yaml Configuration

```yaml
key_config:
  productDescription:
    skipGlobalIgnore: true

  specialOffer:
    key_ignore_phrases:
      - "exclusive"
      - "deal"
```

#### 🔹 skipGlobalIgnore (Bypass Global Ignore List)

```yaml
key_config:
  productDescription:
    skipGlobalIgnore: true
```

•  By default, words in  **global_ignore_phrases**  are not translated.
•  **skipGlobalIgnore: true**  forces  **everything**  in  productDescription  to be translated.
•  Useful when  **some keys need full translations**  without restrictions.

##### 📌 Example Behavior

•  Suppose "service" is in global_ignore_phrases.
•  Normally, it would not be translated.
•  But **for productDescription, it will be translated** because skipGlobalIgnore: true.

#### 🔹 key_ignore_phrases (Per-Key Ignore List)

```yaml
key_config:
  specialOffer:
    key_ignore_phrases:
      - "exclusive"
      - "deal"
```

•  Unlike  **global_ignore_phrases**, this only affects  **one key**.
• "exclusive" and "deal"  **will not be translated**, but **everything else will**.

##### 📌 Example Behavior

• **English:**  "This exclusive deal is available for a limited time!"
• **Spanish Translation:**  "¡Esta exclusive deal está disponible por un tiempo limitado!"
•  "exclusive"  and  "deal"  remain in English.

### 📌 Key Differences Between Global and Key-Level Ignores

|**Feature**|global_ignore_phrases  | key_ignore_phrases |
|--|--|--|
| **Affects all keys** | ✅ Yes | ❌ No (only one key) |
| **Can be bypassed?** | ✅ Yes (skipGlobalIgnore: true) | ❌ No |
| **Good for** | Brand names, technical terms | Case-by-case exceptions|

## 📌 Example Full l10n.yaml Configuration

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart

languages:
  - en
  - es
  - fr

global_ignore_phrases:
  - "Flutter"
  - "Dart"
  - "Google"

key_config:
  productDescription:
    skipGlobalIgnore: true
  specialCase:
    key_ignore_phrases:
      - "exclusive"
      - "deal"
```

### 📌 This setup ensures

•  "Flutter",  "Dart", and  "Google"  will  **never**  be translated.
• "exclusive" and "deal" will be **ignored only in specialCase**.
• productDescription  **will translate everything**, even globally igno

## 💡 Contributing

Contributions are welcome! If you find a bug or want to suggest an improvement, please open an  **issue**  or submit a  **pull request**  on GitHub.

## 📜 License

This project is licensed under the  **MIT License**.
