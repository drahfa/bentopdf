import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/shared/services/pdf_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/pdf_security_service.dart';
import 'package:pdfcow/shared/services/image_conversion_service.dart';

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

final pdfManipulationServiceProvider = Provider<PdfManipulationService>((ref) {
  return PdfManipulationService();
});

final pdfSecurityServiceProvider = Provider<PdfSecurityService>((ref) {
  return PdfSecurityService();
});

final imageConversionServiceProvider = Provider<ImageConversionService>((ref) {
  return ImageConversionService();
});

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
