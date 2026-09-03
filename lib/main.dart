import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LexifyApp());
}

class LexifyApp extends StatelessWidget {
  const LexifyApp({super.key});

  /// UI languages, English first. Flutter's default resolution hands a device
  /// language we do not ship (German, say) the *first* entry of this list, and
  /// the generated [AppLocalizations.supportedLocales] is alphabetical — which
  /// would make Czech the fallback for the whole world.
  static const List<Locale> supportedLocales = [Locale('en'), Locale('cs')];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // Every user-visible string comes from lib/l10n. The device locale picks
      // the language and anything not shipped falls back to English, so the
      // chrome is always in one language — App Review rejected 2.2.2 for
      // mixing Czech and English on the same screen (guideline 4).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
