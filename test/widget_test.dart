import 'package:flutter_test/flutter_test.dart';
import 'package:bibliotheque_app/main.dart';

void main() {
  testWidgets('LibraryFlow démarre correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliothequeApp());

    await tester.pump();

    expect(find.byType(BibliothequeApp), findsOneWidget);
  });
}
