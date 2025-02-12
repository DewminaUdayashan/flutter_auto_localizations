
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
enable-cache: true # Enables caching for optimized translations

languages:
  - si
  - es
  - fr
```

##### 🔹 Find supported translation languages [here](https://cloud.google.com/translate/docs/languages).

### 2. Create the ARB Directory and Default ARB File

After configuring l10n.yaml, create the localization directory and the default ARB file as specified in **arb-dir** and **template-arb-file**.

##### 📌 Example app_en.arb File

```json
{
  "title": "Welcome to My App",
  "welcomeMessage": "Hello, {username}!",
  "cartItems": "{count, plural, zero{Your cart is empty} one{You have one item} other{You have {count} items}}",
  "@cartItems": {
    "description": "Pluralized message for cart items."
  }
}
```

### 2. Set Up Google Cloud Translation API

To enable automatic translations, follow these steps:

#### 🔑 Create an API Key & Configure Google Cloud Console

- Create an API key from  [**Google Cloud Console**](https://console.cloud.google.com/).
- Enable  [**Cloud Translation API**](https://cloud.google.com/translate).
- Billing must be enabled to use this API.

>💡 Google offers free translations for the first 500,000 characters per month (equivalent to $10 free credit monthly). After 500,000 characters, the cost is $20 per million characters.

> ⚠️  **Important:** These prices and quota might be changed over time. Always check the latest  [**pricing details**](https://cloud.google.com/translate/pricing#basic-pricing).

### 3. Store API Key Securely**

- Create a  **.env**  file in your project’s root directory.
- Add your API key like this:

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

### 🌐 Global Configuration

#### 🔹 enable-cache

```yaml
enable-cache: true
```

- Enables caching to **reduce API calls** and **optimize translations**.
- Set to false to **always fetch fresh translations**.

#### 🔹 arb-dir

```yaml
arb-dir: lib/l10n
```

- Defines the  **directory**  where  .arb  (Application Resource Bundle) files are stored.

#### 🔹 template-arb-file

```yaml
template-arb-file: app_en.arb
```

- Specifies the  **base ARB file**  used as a reference for translations.
- **Must be located inside the arb-dir directory.**
- The  **default language**  is inferred from this filename (app_en.arb  →  en).

#### 🔹 output-localization-file

```yaml
output-localization-file: app_localizations.dart
```

- Defines the  **Dart file**  where the localization implementation will be generated.

#### 🔹 languages

```yaml
languages:
  - en
  - es
  - fr
```

- A list of  **languages**  to be generated from the template ARB file.
- ARB file will be generated to each specified language.
- **Supported languages:**  See  [Google Cloud Translate Docs](https://cloud.google.com/translate/docs/languages)

#### 🔹 global-ignore-phrases

```yaml
global-ignore-phrases:
  - "Technology"
  - "Notebook"
  - "Settings"
```
- These settings help **control how translations handle specific words and phrases**.
- Defines **words/phrases that should never be translated**, **across all keys**.
- Useful for **brand names, technical terms, or proper nouns**.
- These phrases will **always remain in their original language** and **case sensitive**.

##### 📌 Example

If Technology is in global_ignore_phrases, then:
- **English:**  "Latest Technology"
- **Spanish Translation:**  "Última Technology" (**Technology remains unchanged!**)

### 📍 Key Level Configuration

#### 🔹 key-config (Per-Key Customization)

Defines  **per-key translation behavior**  by allowing you to  **override global settings**  or specify custom ignore phrases for individual translation keys.

To customize translations for a specific key,  **use the key name from your ARB file**  and define configurations under  key-config.

##### 📌 How it works

- Each  **key in your ARB file**  can have its own configuration.
- Use  **skip-global-ignore**  to bypass the global ignore list.
- Use  **key-ignore-phrases**  to specify words that should not be translated for that key.

##### 📌 Example ARB File (app_en.arb)

```json
{
  "productDescription": "This is a premium service available worldwide.",
  "specialOffer": "This exclusive deal is available for a limited time!"
}
```

##### 📌 Corresponding l10n.yaml Configuration

```yaml
key-config:
  productDescription:
    skip-global-ignore: true

  specialOffer:
    key-ignore-phrases:
      - "exclusive"
      - "deal"
```

#### 🔹 skip-global-ignore

```yaml
key-config:
  productDescription:
    skip-global-ignore: true
```

- **skip-global-ignore: true** forces **everything** in productDescription to be translated without considering global-ignore-phrases.
- Useful when **some keys need full translations** without restrictions.

##### 📌 Example Behavior

- Suppose "service" is in global_ignore_phrases.
- Normally, it would not be translated.
- But **for productDescription, it will be translated** because `skip-global-ignore: true`.

#### 🔹 key-ignore-phrases

```yaml
key-config:
  specialOffer:
    key-ignore-phrases:
      - "exclusive"
      - "deal"
```

- Unlike  **global-ignore-phrases**, this only affects  **one key**.
- "exclusive" and "deal"  **will not be translated**, but **everything else will**.

##### 📌 Example Behavior

- **English:**  "This exclusive deal is available for a limited time!"
- **Spanish Translation:**  "¡Esta exclusive deal está disponible por un tiempo limitado!"
("exclusive"  and  "deal"  remain in English.)

#### 🔹 no-cache

```yaml
key-config:
  specialOffer:
    no-cache: true
```

- The specific key will not use the cached translations, but always use the API for translation.

#### 🔹 ignore

```yaml
key-config:
  specialOffer:
    ignore: true
```

- The specific key will be excluded from the translation.


### 📌 Key Differences Between Global and Key-Level Ignores

|**Feature**|global-ignore-phrases  | key-ignore-phrases |
|--|--|--|
| **Affects all keys** | ✅ Yes | ❌ No (only one key) |
| **Can be bypassed?** | ✅ Yes (skip-global-ignore: true) | ❌ No |
| **Good for** | Brand names, technical terms | Case-by-case exceptions|

## 📌 Example Full l10n.yaml Configuration

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
enable-cache: true

languages:
  - en
  - es
  - fr

global-ignore-phrases:
  - "Flutter"
  - "Dart"
  - "Running Man"

key_config:
  productDescription:
    skip-global-ignore: true
  specialCase:
    key-ignore-phrases:
      - "exclusive"
      - "deal"
  cartItems:
    ignore: true
  cartEmptyState:
    no-cache: true
```

### 📌 This setup ensures

- "Flutter",  "Dart", and  "Running Man"  will  **never**  be translated.
- "exclusive" and "deal" will be **ignored only in specialCase**.
- productDescription  **will translate everything**, not considering `global-ignore-phrases`.
- `cartItems` will not be translated.
- `cartEmptyState` will be translated, however it will not consider cached translations.

## 💡 Contributing

Contributions are welcome! If you find a bug or want to suggest an improvement, please open an  **issue**  or submit a  **pull request**  on GitHub.

## ☕ Support the Project  

If you find this package helpful and want to support its development, consider **buying me a coffee**!  

[![Buy Me a Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/dewmina)  

Your support helps keep the project updated and maintained. Thank you! ❤️

## 📜 License

This project is licensed under the  **MIT License**.
