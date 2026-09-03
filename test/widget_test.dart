import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:short_drama/main.dart';
import 'package:short_drama/providers/app_state.dart';

void main() {
  testWidgets('Short Drama app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const ShortDramaApp(),
      ),
    );
    expect(find.byType(ShortDramaApp), findsOneWidget);
    expect(find.text('Drama'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('My List'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}

