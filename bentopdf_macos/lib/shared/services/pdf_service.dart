import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<pw.Document> loadPdfDocument(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return pw.Document.load(bytes);
  }

  Future<List<pw.Page>> getPdfPages(String filePath) async {
    final doc = await loadPdfDocument(filePath);
    return doc.document.pages;
  }

  Future<int> getPageCount(String filePath) async {
    final pages = await getPdfPages(filePath);
    return pages.length;
  }

  Future<Uint8List> mergePdfs(List<String> filePaths) async {
    final mergedDoc = pw.Document();

    for (final path in filePaths) {
      final doc = await loadPdfDocument(path);
      for (final page in doc.document.pages) {
        mergedDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(),
            ),
          ),
        );
      }
    }

    return mergedDoc.save();
  }

  Future<Uint8List> rotatePdf(String filePath, int rotationDegrees) async {
    final doc = await loadPdfDocument(filePath);
    final rotatedDoc = pw.Document();

    for (final page in doc.document.pages) {
      rotatedDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Transform.rotate(
            angle: rotationDegrees * 3.14159 / 180,
            child: pw.Container(),
          ),
        ),
      );
    }

    return rotatedDoc.save();
  }

  Future<Uint8List> extractPages(String filePath, List<int> pageIndices) async {
    final doc = await loadPdfDocument(filePath);
    final extractedDoc = pw.Document();
    final pages = doc.document.pages;

    for (final index in pageIndices) {
      if (index >= 0 && index < pages.length) {
        extractedDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.Container(),
          ),
        );
      }
    }

    return extractedDoc.save();
  }

  Future<Uint8List> deletePages(String filePath, List<int> pageIndices) async {
    final doc = await loadPdfDocument(filePath);
    final newDoc = pw.Document();
    final pages = doc.document.pages;

    for (int i = 0; i < pages.length; i++) {
      if (!pageIndices.contains(i)) {
        newDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.Container(),
          ),
        );
      }
    }

    return newDoc.save();
  }

  Future<void> savePdf(Uint8List data, String outputPath) async {
    final file = File(outputPath);
    await file.writeAsBytes(data);
  }
}
