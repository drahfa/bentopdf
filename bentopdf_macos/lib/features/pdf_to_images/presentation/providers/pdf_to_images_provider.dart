import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/image_conversion_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'dart:io';

class PdfToImagesState {
  final String? filePath;
  final int? pageCount;
  final ImageFormat format;
  final int quality;
  final bool isProcessing;
  final List<String>? outputPaths;
  final String? error;
  final String? successMessage;

  const PdfToImagesState({
    this.filePath,
    this.pageCount,
    this.format = ImageFormat.png,
    this.quality = 95,
    this.isProcessing = false,
    this.outputPaths,
    this.error,
    this.successMessage,
  });

  PdfToImagesState copyWith({
    String? filePath,
    int? pageCount,
    ImageFormat? format,
    int? quality,
    bool? isProcessing,
    List<String>? outputPaths,
    String? error,
    String? successMessage,
  }) {
    return PdfToImagesState(
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      format: format ?? this.format,
      quality: quality ?? this.quality,
      isProcessing: isProcessing ?? this.isProcessing,
      outputPaths: outputPaths,
      error: error,
      successMessage: successMessage,
    );
  }
}

class PdfToImagesNotifier extends StateNotifier<PdfToImagesState> {
  final ImageConversionService _conversionService;
  final FileService _fileService;

  PdfToImagesNotifier(this._conversionService, this._fileService)
      : super(const PdfToImagesState());

  Future<void> selectFile() async {
    final filePath = await _fileService.pickPdfFile();
    if (filePath == null) return;

    try {
      final pageCount = await _conversionService._getPageCount(filePath);
      state = state.copyWith(
        filePath: filePath,
        pageCount: pageCount,
        error: null,
        outputPaths: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error loading PDF: ${e.toString()}');
    }
  }

  void setFormat(ImageFormat format) {
    state = state.copyWith(format: format, error: null);
  }

  void setQuality(int quality) {
    state = state.copyWith(quality: quality, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null, outputPaths: null);
  }

  Future<void> convertToImages() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputDir = '${tempDir.path}/pdf_to_images_$timestamp';

      final outputPaths = await _conversionService.convertPdfToImages(
        state.filePath!,
        outputDir,
        state.format,
        quality: state.quality,
      );

      final saveDir = await _fileService.getDirectoryPath();

      if (saveDir != null) {
        final newOutputPaths = <String>[];
        for (final path in outputPaths) {
          final fileName = path.split('/').last;
          final newPath = '$saveDir/$fileName';
          await File(path).copy(newPath);
          newOutputPaths.add(newPath);
        }

        await Directory(outputDir).delete(recursive: true);

        state = state.copyWith(
          isProcessing: false,
          successMessage:
              '${outputPaths.length} image(s) saved successfully!',
          outputPaths: newOutputPaths,
        );
      } else {
        await Directory(outputDir).delete(recursive: true);
        state = state.copyWith(
          isProcessing: false,
          error: 'Save cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error converting PDF: ${e.toString()}',
      );
    }
  }
}

extension on ImageConversionService {
  Future<int> _getPageCount(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = await pdfx.PdfDocument.openData(bytes);
    final count = document.pagesCount;
    await document.close();
    return count;
  }
}

final pdfToImagesProvider =
    StateNotifierProvider<PdfToImagesNotifier, PdfToImagesState>((ref) {
  return PdfToImagesNotifier(
    ref.watch(imageConversionServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
