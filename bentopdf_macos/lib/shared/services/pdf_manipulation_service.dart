import 'dart:io';
import 'dart:typed_data';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfManipulationService {
  // Render scale factor for better quality (3.0 = 216 DPI)
  static const double _renderScale = 3.0;

  Future<Uint8List> mergePdfs(List<String> filePaths) async {
    if (filePaths.isEmpty) {
      throw ArgumentError('File paths list cannot be empty');
    }
    if (filePaths.length < 2) {
      throw ArgumentError('At least 2 PDF files are required for merging');
    }

    final mergedDoc = pw.Document();

    for (final path in filePaths) {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final document = await pdfx.PdfDocument.openData(bytes);

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * _renderScale,
          height: page.height * _renderScale,
          format: pdfx.PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage != null) {
          final image = pw.MemoryImage(pageImage.bytes);
          mergedDoc.addPage(
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
    }

    return mergedDoc.save();
  }

  Future<int> getPageCount(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final count = document.pagesCount;
    await document.close();
    return count;
  }

  Future<Uint8List> extractPages(
    String filePath,
    List<int> pageNumbers,
  ) async {
    if (pageNumbers.isEmpty) {
      throw ArgumentError('Page numbers list cannot be empty');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final extractedDoc = pw.Document();

    for (final pageNum in pageNumbers) {
      if (pageNum >= 1 && pageNum <= document.pagesCount) {
        final page = await document.getPage(pageNum);
        final pageImage = await page.render(
          width: page.width * _renderScale,
          height: page.height * _renderScale,
          format: pdfx.PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage != null) {
          final image = pw.MemoryImage(pageImage.bytes);
          extractedDoc.addPage(
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
    }

    await document.close();
    return extractedDoc.save();
  }

  Future<Uint8List> deletePages(
    String filePath,
    List<int> pageNumbersToDelete,
  ) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final newDoc = pw.Document();

    for (int i = 1; i <= document.pagesCount; i++) {
      if (!pageNumbersToDelete.contains(i)) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * _renderScale,
          height: page.height * _renderScale,
          format: pdfx.PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage != null) {
          final image = pw.MemoryImage(pageImage.bytes);
          newDoc.addPage(
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
    }

    await document.close();
    return newDoc.save();
  }

  Future<Uint8List> rotatePdf(
    String filePath,
    int rotationDegrees,
  ) async {
    if (![90, 180, 270].contains(rotationDegrees)) {
      throw ArgumentError('Rotation degrees must be 90, 180, or 270');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final rotatedDoc = pw.Document();

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * _renderScale,
        height: page.height * _renderScale,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();

      if (pageImage != null) {
        final image = pw.MemoryImage(pageImage.bytes);
        final isRotated90or270 = rotationDegrees == 90 || rotationDegrees == 270;

        rotatedDoc.addPage(
          pw.Page(
            pageFormat: isRotated90or270
                ? PdfPageFormat(page.height, page.width)
                : PdfPageFormat(page.width, page.height),
            build: (context) => pw.Center(
              child: pw.Transform.rotate(
                angle: rotationDegrees * 3.14159 / 180,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
          ),
        );
      }
    }

    await document.close();
    return rotatedDoc.save();
  }

  Future<void> savePdf(Uint8List data, String outputPath) async {
    final file = File(outputPath);
    await file.writeAsBytes(data);
  }
}
