import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app.dart';

void main() {
  testWidgets('renders login flow entry point', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WiraSasaApp()));

    expect(find.text('How it works'), findsOneWidget);
    expect(find.text('Enter mobile number'), findsOneWidget);
  });
}
