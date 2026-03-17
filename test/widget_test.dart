import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:color_palette/main.dart';

void main() {
  testWidgets('App launches and shows ColorPalette title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ColorPaletteApp()),
    );
    expect(find.text('ColorPalette'), findsOneWidget);
  });
}
