import 'package:flutter_test/flutter_test.dart';
import 'package:agremate_admin/main.dart';
import 'package:agremate_admin/routes/app_routes.dart';

void main() {
  testWidgets('Login view smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgremateAdmin(initialRoute: AppRoutes.login));
    expect(find.text('Agremate Dashboard'), findsOneWidget);
  });
}
