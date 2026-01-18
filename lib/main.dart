import 'package:flutter/material.dart';
import 'screens/deck_screen.dart';

void main() {
  runApp(const DuolingoCardsApp());
}

class DuolingoCardsApp extends StatelessWidget {
  const DuolingoCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DuolingoCards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DeckScreen(),
    );
  }
}
