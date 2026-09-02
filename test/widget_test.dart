import 'package:flutter_test/flutter_test.dart';
import 'package:short_drama/main.dart';

void main() {
  testWidgets('Short Drama app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShortDramaApp());
    expect(find.text('Short Drama'), findsWidgets);
  });
}
