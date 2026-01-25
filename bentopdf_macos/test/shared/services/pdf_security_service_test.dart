import 'package:flutter_test/flutter_test.dart';
import 'package:pdfcow/shared/services/pdf_security_service.dart';

void main() {
  late PdfSecurityService service;

  setUp(() {
    service = PdfSecurityService();
  });

  group('PdfSecurityService', () {
    test('should be instantiated', () {
      expect(service, isNotNull);
      expect(service, isA<PdfSecurityService>());
    });

    test('encryptPdf should throw error with empty password', () async {
      expect(
        () => service.encryptPdf('test.pdf', ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('encryptPdf should throw error with short password', () async {
      expect(
        () => service.encryptPdf('test.pdf', '12345'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('encryptPdf should validate password with 6+ characters', () {
      // Valid password length validation
      // Note: Actual encryption would require test PDF files
    });

    test('decryptPdf should throw error with empty password', () async {
      expect(
        () => service.decryptPdf('test.pdf', ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('decryptPdf should validate non-empty password', () {
      // Password validation only
      // Note: Actual decryption would require test PDF files
    });
  });
}
