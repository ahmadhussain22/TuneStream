import 'package:flutter_test/flutter_test.dart';
import 'package:tunestream/main.dart'; // adjust if your package name is different

void main() {
  testWidgets('TuneStream UI loads properly', (WidgetTester tester) async {
    // Build the TuneStream app and trigger a frame.
    await tester.pumpWidget(TuneStreamApp());

    // Wait for any animations or builds to complete.
    await tester.pumpAndSettle();

    // Verify that app bar title "TuneStream" appears.
    expect(find.text('TuneStream'), findsOneWidget);

    // Verify that Home, Search, Library tabs exist.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
