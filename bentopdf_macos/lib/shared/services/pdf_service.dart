import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<Uint8List> createBlankPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Text('Blank Page'),
        ),
      ),
    );
    return doc.save();
  }

  Future<void> savePdf(Uint8List data, String outputPath) async {
    final file = File(outputPath);
    await file.writeAsBytes(data);
  }

  Future<Uint8List> readPdfFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }
}
