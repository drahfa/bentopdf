import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdfcow/features/home/presentation/pages/home_page.dart';
import 'package:pdfcow/features/home/presentation/widgets/tool_card.dart';
import 'package:pdfcow/shared/models/tool_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget() {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  group('HomePage Widget', () {
    testWidgets('should display app title in AppBar', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('PDFcow: PDF Editor'), findsOneWidget);
    });

    testWidgets('should display tagline', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Your Friendly PDF Editor'), findsOneWidget);
    });

    testWidgets('should display subtitle', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Merge, split, rotate, organize, and secure'),
        findsOneWidget,
      );
    });

    testWidgets('should display tool cards', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ToolCard), findsNWidgets(ToolsConfig.tools.length));
    });

    testWidgets('should display GridView with tool cards', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display settings icon button', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should render 10 tools', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ToolCard), findsNWidgets(10));
    });
  });
}
