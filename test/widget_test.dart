import 'package:flutter_test/flutter_test.dart';
import 'package:agremate_admin/main.dart';

void main() {
  testWidgets('Login view smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgremateAdmin());

    // Verify that our branding exists.
    expect(find.text('AGREMATE'), findsOneWidget);
    expect(find.text('Sign In'), findsNWidgets(2)); // Card title + Button text
    expect(find.text('Super Admin Dashboard'), findsOneWidget);
  });
}
