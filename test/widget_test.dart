import 'package:flutter_test/flutter_test.dart';
import 'package:drone_monitoring/main.dart'; // Correct package name matching pubspec.yaml

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title Drone Monitoring is present in the AppBar or NavigationBar.
    expect(find.text('Drone Monitoring'), findsWidgets);
  });
}
