import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdfcow/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches with home page', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await EasyLocalization.ensureInitialized();
    });

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const PdfCowApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PDFcow: PDF Editor'), findsOneWidget);
    expect(find.text('Your Friendly PDF Editor'), findsOneWidget);
  });
}
