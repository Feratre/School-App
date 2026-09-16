import 'package:flutter_test/flutter_test.dart';
import 'package:school_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SchoolMasterApp());
    expect(find.byType(SchoolMasterApp), findsOneWidget);
  });
}
