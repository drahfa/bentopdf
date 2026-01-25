import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class RotatePdfState {
  final String? filePath;
  final int? pageCount;
  final int rotationDegrees;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const RotatePdfState({
    this.filePath,
    this.pageCount,
    this.rotationDegrees = 90,
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  RotatePdfState copyWith({
    String? filePath,
    int? pageCount,
    int? rotationDegrees,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return RotatePdfState(
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class RotatePdfNotifier extends StateNotifier<RotatePdfState> {
  final PdfManipulationService _pdfService;
  final FileService _fileService;

  RotatePdfNotifier(this._pdfService, this._fileService)
      : super(const RotatePdfState());

  Future<void> selectFile() async {
    final filePath = await _fileService.pickPdfFile();
    if (filePath == null) return;

    try {
      final pageCount = await _pdfService.getPageCount(filePath);
      state = state.copyWith(
        filePath: filePath,
        pageCount: pageCount,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error loading PDF: ${e.toString()}');
    }
  }

  void setRotation(int degrees) {
    state = state.copyWith(rotationDegrees: degrees, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> rotatePdf() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final rotatedData = await _pdfService.rotatePdf(
        state.filePath!,
        state.rotationDegrees,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'rotated_${state.rotationDegrees}.pdf',
      );

      if (outputPath != null) {
        await _pdfService.savePdf(rotatedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF rotated successfully!',
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: 'Save cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error rotating PDF: ${e.toString()}',
      );
    }
  }
}

final rotatePdfProvider =
    StateNotifierProvider<RotatePdfNotifier, RotatePdfState>((ref) {
  return RotatePdfNotifier(
    ref.watch(pdfManipulationServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
