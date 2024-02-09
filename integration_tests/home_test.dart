// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cards/components/shared/button.dart';
import 'package:cards/components/shared/textinput.dart';
import 'package:cards/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('E2E - Homescreen', () {
    testWidgets('Saved cards title is rendered', (tester) async {
      // Load app widget.
      await tester.pumpWidget(app);

      // Verify Saved cards title is rendered.
      expect(find.textContaining("Saved cards"), findsOneWidget);
    });

    testWidgets('Add new card button is rendered', (tester) async {
      // Load app widget.
      await tester.pumpWidget(app);

      // Verify add new card button is rendered.
      expect(find.text('Add new card'), findsOneWidget);
    });

    testWidgets(
        'Form opens on tapping add new card button, and has 5 input fields and 1 button element.',
        (tester) async {
      // Load app widget.
      await tester.pumpWidget(app);

      await tester.tap(find.widgetWithText(Button, "Add new card"));

      await tester.pumpAndSettle();

      expect(find.byType(TextInputField, skipOffstage: true), findsNWidgets(5));
      expect(find.widgetWithText(Button, "Add new card"), findsNWidgets(1));
      expect(find.widgetWithText(Button, "Close"), findsNWidgets(1));
    });
  });
}
