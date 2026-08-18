import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duolingo_cards/main.dart';
import 'package:duolingo_cards/screens/home_screen.dart';

void main() {
  testWidgets('App boots into HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const DuolingoCardsApp());

    // First frame: the deck list is still loading (entitlements + assets are
    // resolved asynchronously), so assert on the boot path, not on deck names.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
