import 'package:flutter_test/flutter_test.dart';
import 'package:bacheca/main.dart';

void main() {
  testWidgets('Avvio app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BachecaApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(BachecaApp), findsOneWidget);
  });
}
