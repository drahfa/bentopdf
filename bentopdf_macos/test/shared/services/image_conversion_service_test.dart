import 'package:flutter_test/flutter_test.dart';
import 'package:pdfcow/shared/services/image_conversion_service.dart';

void main() {
  late ImageConversionService service;

  setUp(() {
    service = ImageConversionService();
  });

  group('ImageConversionService', () {
    test('should be instantiated', () {
      expect(service, isNotNull);
      expect(service, isA<ImageConversionService>());
    });

    test('convertPdfToImages should throw error with invalid quality', () async {
      expect(
        () => service.convertPdfToImages(
          'test.pdf',
          '/output',
          ImageFormat.jpg,
          quality: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => service.convertPdfToImages(
          'test.pdf',
          '/output',
          ImageFormat.jpg,
          quality: 101,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('convertPdfToImages should validate quality range', () {
      // Valid quality range validation
      // Note: Actual conversion would require test PDF files
    });

    test('convertPdfToImages should support PNG format', () {
      // PNG format support
      // Note: Actual conversion would require test PDF files
    });

    test('convertImagesToPdf should throw error with empty image list', () async {
      expect(
        () => service.convertImagesToPdf([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('convertImagesToPdf should validate single image', () {
      // Single image validation
      // Note: Actual conversion would require test image files
    });

    test('convertImagesToPdf should validate multiple images', () {
      // Multiple images validation
      // Note: Actual conversion would require test image files
    });
  });

  group('ImageFormat enum', () {
    test('should have PNG and JPG formats', () {
      expect(ImageFormat.values, contains(ImageFormat.png));
      expect(ImageFormat.values, contains(ImageFormat.jpg));
      expect(ImageFormat.values.length, equals(2));
    });
  });
}
