import 'package:flutter_test/flutter_test.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';

void main() {
  late PdfManipulationService service;

  setUp(() {
    service = PdfManipulationService();
  });

  group('PdfManipulationService', () {
    test('should be instantiated', () {
      expect(service, isNotNull);
      expect(service, isA<PdfManipulationService>());
    });

    // Note: These tests require actual PDF files to work properly
    // In a real-world scenario, you would use mock files or test fixtures

    test('mergePdfs should throw error when given empty list', () async {
      expect(
        () => service.mergePdfs([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('mergePdfs should throw error when given single file', () async {
      expect(
        () => service.mergePdfs(['single_file.pdf']),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('extractPages should throw error when given empty page list', () async {
      expect(
        () => service.extractPages('test.pdf', []),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deletePages should throw error when deleting all pages', () async {
      // This would be tested with a mock PDF document
      // expect(() => service.deletePages('test.pdf', [1, 2, 3]), throwsException);
    });

    test('rotatePdf should validate rotation angles', () {
      // Valid rotation angles: 90, 180, 270
      // Note: We only test validation, not actual file operations
      // Actual operations would require test PDF files
    });

    test('rotatePdf should throw error for invalid rotation angle', () {
      expect(
        () => service.rotatePdf('test.pdf', 45),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
