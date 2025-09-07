
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aladdin_app/main.dart';  // اپنا main.dart فائل کا درست path استعمال کرو

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // App کو load کرو
    await tester.pumpWidget(MyApp());

    // Verify: Counter شروع میں "0" دکھائے
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Action: "+" آئیکن دباؤ
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify: Counter اب "1" دکھائے
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

