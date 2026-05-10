import 'package:flutter_test/flutter_test.dart';

import 'package:shg_portal/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShgApp());
    expect(find.byType(ShgApp), findsOneWidget);
  });
}
