import 'package:flutter_test/flutter_test.dart';
import 'package:dose_tracker/main.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const DoseTrackerApp());
    expect(find.text('Today'), findsOneWidget);
  });
}
