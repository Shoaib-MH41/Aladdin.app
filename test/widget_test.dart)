
import 'package:flutter_test/flutter_test.dart';
import 'package:aladdin_app/main.dart';

void main() {
  testWidgets('Counter increments test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}


