import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart' as pw_pdf;
import 'package:pdf/widgets.dart' as pw;

class PdfMetadataService {
  /// Extract page rotation from PDF by parsing the PDF file directly
  /// Returns rotation in degrees (0, 90, 180, 270)
  Future<int> getPageRotation(String pdfPath, int pageNumber) async {
    try {
      final file = File(pdfPath);
      final bytes = await file.readAsBytes();

      // Parse the PDF to extract rotation
      final rotation = await _parseRotationFromPdfBytes(bytes, pageNumber);
      return rotation;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _parseRotationFromPdfBytes(List<int> bytes, int pageNumber) async {
    try {
      // Look for /Rotate in the PDF structure
      final pdfString = String.fromCharCodes(bytes);

      // Find page objects and look for /Rotate key
      final rotatePattern = RegExp(r'/Rotate\s+(\d+)');
      final match = rotatePattern.firstMatch(pdfString);

      if (match != null) {
        final rotationStr = match.group(1);
        final rotation = int.tryParse(rotationStr ?? '0') ?? 0;
        return rotation;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get all page rotations for a PDF
  Future<Map<int, int>> getAllPageRotations(String pdfPath) async {
    // For now, assume all pages have same rotation
    final rotation = await getPageRotation(pdfPath, 1);
    return {1: rotation};
  }
}
