import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auto Localizations',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message (Basic)
            Text(localizations.welcomeMessage('John')),

            SizedBox(height: 20),

            // ICU Plural Message
            Text(localizations.cartItems(2)),
            Text(localizations.followersCount(1)),
            Text(localizations.followersCount(100)),

            SizedBox(height: 20),

            // ICU Select Message
            Text(localizations.genderSelection('male')),
            Text(localizations.genderSelection('female')),
            Text(localizations.genderSelection('other')),

            SizedBox(height: 20),

            // ICU Select + Plural Combined
            Text(localizations.notificationCount(0)),
            Text(localizations.notificationCount(1)),
            Text(localizations.notificationCount(5)),

            SizedBox(height: 20),

            // Select Example for User Roles
            Text(localizations.userRole('admin')),
            Text(localizations.userRole('user')),
            Text(localizations.userRole('guest')),
          ],
        ),
      ),
    );
  }
}
