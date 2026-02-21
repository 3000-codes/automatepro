import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automatepro/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AutoMateApp()));
    await tester.pumpAndSettle();

    expect(find.text('AutoMate Pro'), findsOneWidget);
  });
}
