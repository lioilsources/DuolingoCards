import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LexifyApp());
}

class LexifyApp extends StatelessWidget {
  const LexifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
