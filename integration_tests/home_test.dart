// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cards/screens/home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('E2E - Homescreen', () {
    testWidgets('Hello world is rendered', (tester) async {
      // Load app widget.
      await tester.pumpWidget(const Home());

      // Verify hello world is rendered.
      expect(find.text("Hello, world"), findsOneWidget);
    });

    testWidgets('Subtitle text is rendered', (tester) async {
      // Load app widget.
      await tester.pumpWidget(const Home());

      // Verify sub text is rendered.
      expect(find.text('one two three 1234567890'), findsOneWidget);
    });
  });
}
