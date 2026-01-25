import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

void main() {
  Widget createTestWidget({
    String? selectedFilePath,
    int? pageCount,
    required VoidCallback onSelectFile,
    String? emptyStateTitle,
    String? emptyStateSubtitle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PdfFileSelector(
          selectedFilePath: selectedFilePath,
          pageCount: pageCount,
          onSelectFile: onSelectFile,
          emptyStateTitle: emptyStateTitle,
          emptyStateSubtitle: emptyStateSubtitle,
        ),
      ),
    );
  }

  group('PdfFileSelector Widget', () {
    testWidgets('should display empty state when no file selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        onSelectFile: () {},
        emptyStateTitle: 'Test Title',
        emptyStateSubtitle: 'Test Subtitle',
      ));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('should display selected file when file is chosen',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        selectedFilePath: '/path/to/document.pdf',
        pageCount: 5,
        onSelectFile: () {},
      ));

      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('5 pages'), findsOneWidget);
    });

    testWidgets('should show Choose PDF File button in empty state',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        onSelectFile: () => tapped = true,
      ));

      expect(find.text('Choose PDF File'), findsOneWidget);

      await tester.tap(find.text('Choose PDF File'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should show Change button when file selected',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        selectedFilePath: '/path/to/test.pdf',
        pageCount: 3,
        onSelectFile: () => tapped = true,
      ));

      expect(find.text('Change'), findsOneWidget);

      await tester.tap(find.text('Change'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should display PDF icon for selected file', (tester) async {
      await tester.pumpWidget(createTestWidget(
        selectedFilePath: '/path/to/document.pdf',
        pageCount: 2,
        onSelectFile: () {},
      ));

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('should use default title when none provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        onSelectFile: () {},
      ));

      expect(find.text('Select or drop PDF file'), findsOneWidget);
    });

    testWidgets('should use default subtitle when none provided',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        onSelectFile: () {},
      ));

      expect(
        find.text('Drag and drop a PDF file here, or click below'),
        findsOneWidget,
      );
    });
  });
}
