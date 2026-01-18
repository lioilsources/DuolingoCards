import 'package:flutter_test/flutter_test.dart';
import 'package:duolingo_cards/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DuolingoCardsApp());
    expect(find.text('Základní japonština'), findsOneWidget);
  });
}
