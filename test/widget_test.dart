import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/main.dart';

void main() {
  testWidgets('SuperHealthApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SuperHealthApp(),
      ),
    );

    // Allow splash animation and timer to complete smoothly
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify app loaded cleanly
    expect(find.byType(SuperHealthApp), findsOneWidget);
  });
}
