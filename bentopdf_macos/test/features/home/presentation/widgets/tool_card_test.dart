import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdfcow/features/home/presentation/widgets/tool_card.dart';
import 'package:pdfcow/shared/models/tool_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(ToolInfo tool) {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MaterialApp(
        home: Scaffold(
          body: ToolCard(tool: tool),
        ),
      ),
    );
  }

  group('ToolCard Widget', () {
    testWidgets('should display tool name and description', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      const testTool = ToolInfo(
        id: 'test-tool',
        name: 'tools.merge_pdf.name',
        description: 'tools.merge_pdf.description',
        icon: Icons.merge,
        route: '/test',
      );

      await tester.pumpWidget(createTestWidget(testTool));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.merge), findsOneWidget);
      expect(find.text('Merge PDF'), findsOneWidget);
      expect(find.text('Combine multiple PDFs into one'), findsOneWidget);
    });

    testWidgets('should be tappable when available', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      const testTool = ToolInfo(
        id: 'test-tool',
        name: 'tools.split_pdf.name',
        description: 'tools.split_pdf.description',
        icon: Icons.call_split,
        route: '/test',
        isAvailable: true,
      );

      await tester.pumpWidget(createTestWidget(testTool));
      await tester.pumpAndSettle();

      final inkWell = find.byType(InkWell);
      expect(inkWell, findsOneWidget);

      expect(tester.widget<InkWell>(inkWell).onTap, isNotNull);
    });

    testWidgets('should not be tappable when unavailable', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      const testTool = ToolInfo(
        id: 'test-tool',
        name: 'tools.rotate_pdf.name',
        description: 'tools.rotate_pdf.description',
        icon: Icons.rotate_90_degrees_cw,
        route: '/test',
        isAvailable: false,
      );

      await tester.pumpWidget(createTestWidget(testTool));
      await tester.pumpAndSettle();

      final inkWell = find.byType(InkWell);
      expect(inkWell, findsOneWidget);

      expect(tester.widget<InkWell>(inkWell).onTap, isNull);
    });

    testWidgets('should render Card widget', (tester) async {
      await tester.runAsync(() async {
        await EasyLocalization.ensureInitialized();
      });

      const testTool = ToolInfo(
        id: 'test-tool',
        name: 'tools.merge_pdf.name',
        description: 'tools.merge_pdf.description',
        icon: Icons.merge,
        route: '/test',
      );

      await tester.pumpWidget(createTestWidget(testTool));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
