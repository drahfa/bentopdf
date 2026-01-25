import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

class PdfSecurityService {
  Future<Uint8List> encryptPdf(String filePath, String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters long');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final encryptedDoc = pw.Document();

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();

      if (pageImage != null) {
        final image = pw.MemoryImage(pageImage.bytes);
        encryptedDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              page.width,
              page.height,
            ),
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }
    }

    await document.close();
    return encryptedDoc.save();
  }

  Future<Uint8List> decryptPdf(String filePath, String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();

    try {
      final document = await pdfx.PdfDocument.openData(bytes, password: password);
      final decryptedDoc = pw.Document();

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: pdfx.PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage != null) {
          final image = pw.MemoryImage(pageImage.bytes);
          decryptedDoc.addPage(
            pw.Page(
              pageFormat: PdfPageFormat(
                page.width,
                page.height,
              ),
              build: (context) => pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
          );
        }
      }

      await document.close();
      return decryptedDoc.save();
    } catch (e) {
      throw Exception('Failed to decrypt PDF. Check password and try again.');
    }
  }

  Future<void> savePdf(Uint8List data, String outputPath) async {
    final file = File(outputPath);
    await file.writeAsBytes(data);
  }
}
