import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo home shows contoured shadow samples', (tester) async {
    await tester.pumpWidget(const ContouredShadowDemo());

    expect(find.text('Contoured Shadow'), findsOneWidget);
    expect(find.text('Product cutout'), findsOneWidget);
    expect(find.text('Icon badge'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_rounded), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Shaped surface'),
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shaped surface'), findsOneWidget);
  });
}
