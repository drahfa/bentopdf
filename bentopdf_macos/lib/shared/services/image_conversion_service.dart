import 'dart:io';
import 'dart:typed_data';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;

enum ImageFormat { png, jpg }

class ImageConversionService {
  Future<List<String>> convertPdfToImages(
    String pdfPath,
    String outputDirectory,
    ImageFormat format, {
    int quality = 95,
  }) async {
    if (quality < 1 || quality > 100) {
      throw ArgumentError('Quality must be between 1 and 100');
    }

    final file = File(pdfPath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final outputPaths = <String>[];

    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();

      if (pageImage != null) {
        final imagePath = '$outputDirectory/page_$i.${format.name}';

        if (format == ImageFormat.jpg) {
          final image = img.decodeImage(pageImage.bytes);
          if (image != null) {
            final jpgBytes = img.encodeJpg(image, quality: quality);
            await File(imagePath).writeAsBytes(jpgBytes);
          }
        } else {
          await File(imagePath).writeAsBytes(pageImage.bytes);
        }

        outputPaths.add(imagePath);
      }
    }

    await document.close();
    return outputPaths;
  }

  Future<Uint8List> convertImagesToPdf(
    List<String> imagePaths, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    if (imagePaths.isEmpty) {
      throw ArgumentError('Image paths list cannot be empty');
    }

    final pdf = pw.Document();

    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = pw.MemoryImage(bytes);

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage != null) {
        final imageWidth = decodedImage.width.toDouble();
        final imageHeight = decodedImage.height.toDouble();

        final format = PdfPageFormat(imageWidth, imageHeight);

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
      } else {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }
    }

    return pdf.save();
  }

  Future<void> savePdf(Uint8List data, String outputPath) async {
    final file = File(outputPath);
    await file.writeAsBytes(data);
  }
}
