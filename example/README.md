# Flutter Auto Localizations Example

## Step 1

- Run the below command to add `flutter localizations` in to your project
  
```bash
flutter pub add flutter_localizations --sdk=flutter
```

- Add the below line in your pubspec.yaml file under `flutter:`

```yaml
  generate: true
```

## Step 2

- Create `l10n.yamal` file in your project root directory.
- Configure required field stated below.
    - arb-dir
    - template-arb-file
    - output-localization-file
    - languages

## Step 3

- Create `.env` file in your project root directory and add the generated API key like below.

```
GOOGLE_TRANSLATE_API_KEY=<YOUR_API_KEY_GOES_HERE>
```

- Add the `.env` file to `.gitignore`

## Step 4

- Create your default arb file in the stated directory in the `l10n.yaml` file

## Step 5

- Run the below command in your terminal.

```bash
dart run flutter_auto_localizations
```
