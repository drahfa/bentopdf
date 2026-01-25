import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import '../../features/pdf_editor/domain/models/annotation_base.dart';
import '../../features/pdf_editor/data/painters/annotation_painter.dart';

class PdfExportService {
  Future<Uint8List> exportPdfWithAnnotations({
    required String originalPdfPath,
    required Map<int, List<AnnotationBase>> annotationsByPage,
    required Function(int current, int total)? onProgress,
    required Map<String, ui.Image> imageCache,
    double scale = 2.0,
  }) async {
    final file = File(originalPdfPath);
    final bytes = await file.readAsBytes();
    final pdfDocument = await pdfx.PdfDocument.openData(bytes);
    final outputDoc = pw.Document();

    try {
      final totalPages = pdfDocument.pagesCount;

      for (int i = 1; i <= totalPages; i++) {
        onProgress?.call(i, totalPages);

        final page = await pdfDocument.getPage(i);

        try {
          final pageWidth = page.width * scale;
          final pageHeight = page.height * scale;

          final pageImage = await page.render(
            width: pageWidth,
            height: pageHeight,
            format: pdfx.PdfPageImageFormat.png,
          );

          if (pageImage == null) {
            throw Exception('Failed to render page $i');
          }

          Uint8List finalImageBytes;

          if (annotationsByPage.containsKey(i) &&
              annotationsByPage[i]!.isNotEmpty) {
            finalImageBytes = await _compositePageWithAnnotations(
              pageImageBytes: pageImage.bytes,
              annotations: annotationsByPage[i]!,
              pageWidth: pageWidth,
              pageHeight: pageHeight,
              imageCache: imageCache,
            );
          } else {
            finalImageBytes = pageImage.bytes;
          }

          final image = pw.MemoryImage(finalImageBytes);

          final pdfPageWidth = pageWidth / PdfPageFormat.point;
          final pdfPageHeight = pageHeight / PdfPageFormat.point;

          outputDoc.addPage(
            pw.Page(
              pageFormat: PdfPageFormat(
                pdfPageWidth,
                pdfPageHeight,
                marginAll: 0,
              ),
              build: (context) => pw.Container(
                width: pdfPageWidth,
                height: pdfPageHeight,
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.fill,
                ),
              ),
            ),
          );
        } finally {
          await page.close();
        }
      }

      return await outputDoc.save();
    } finally {
      await pdfDocument.close();
    }
  }

  Future<Uint8List> _compositePageWithAnnotations({
    required Uint8List pageImageBytes,
    required List<AnnotationBase> annotations,
    required double pageWidth,
    required double pageHeight,
    required Map<String, ui.Image> imageCache,
  }) async {
    final annotationImageBytes = await _renderAnnotationsToImage(
      annotations: annotations,
      width: pageWidth,
      height: pageHeight,
      imageCache: imageCache,
    );

    final originalImg = img.decodeImage(pageImageBytes);
    if (originalImg == null) {
      throw Exception('Failed to decode original page image');
    }

    final annotationImg = img.decodeImage(annotationImageBytes);
    if (annotationImg == null) {
      throw Exception('Failed to decode annotation image');
    }

    img.compositeImage(originalImg, annotationImg);

    return Uint8List.fromList(img.encodePng(originalImg));
  }

  Future<Uint8List> _renderAnnotationsToImage({
    required List<AnnotationBase> annotations,
    required double width,
    required double height,
    required Map<String, ui.Image> imageCache,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      ui.Paint()..color = const ui.Color(0x00000000),
    );

    final painter = AnnotationPainter(
      annotations: annotations,
      imageCache: imageCache,
    );

    painter.paint(canvas, ui.Size(width, height));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      width.toInt(),
      height.toInt(),
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Failed to convert annotation image to bytes');
    }

    return byteData.buffer.asUint8List();
  }

  Future<void> exportToFile({
    required String originalPdfPath,
    required String outputPath,
    required Map<int, List<AnnotationBase>> annotationsByPage,
    required Map<String, ui.Image> imageCache,
    Function(int current, int total)? onProgress,
  }) async {
    final pdfBytes = await exportPdfWithAnnotations(
      originalPdfPath: originalPdfPath,
      annotationsByPage: annotationsByPage,
      onProgress: onProgress,
      imageCache: imageCache,
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pdfBytes);
  }
}
