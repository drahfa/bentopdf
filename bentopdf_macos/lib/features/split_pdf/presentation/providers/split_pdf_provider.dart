import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class SplitPdfState {
  final String? filePath;
  final int? pageCount;
  final String startPage;
  final String endPage;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const SplitPdfState({
    this.filePath,
    this.pageCount,
    this.startPage = '1',
    this.endPage = '',
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  SplitPdfState copyWith({
    String? filePath,
    int? pageCount,
    String? startPage,
    String? endPage,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return SplitPdfState(
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class SplitPdfNotifier extends StateNotifier<SplitPdfState> {
  final PdfManipulationService _pdfService;
  final FileService _fileService;

  SplitPdfNotifier(this._pdfService, this._fileService)
      : super(const SplitPdfState());

  Future<void> selectFile() async {
    final filePath = await _fileService.pickPdfFile();
    if (filePath == null) return;

    try {
      final pageCount = await _pdfService.getPageCount(filePath);
      state = state.copyWith(
        filePath: filePath,
        pageCount: pageCount,
        endPage: pageCount.toString(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error loading PDF: ${e.toString()}');
    }
  }

  void setStartPage(String value) {
    state = state.copyWith(startPage: value, error: null);
  }

  void setEndPage(String value) {
    state = state.copyWith(endPage: value, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> splitPdf() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    final start = int.tryParse(state.startPage);
    final end = int.tryParse(state.endPage);

    if (start == null || end == null) {
      state = state.copyWith(error: 'Please enter valid page numbers');
      return;
    }

    if (start < 1 || end > (state.pageCount ?? 0) || start > end) {
      state = state.copyWith(
          error: 'Invalid page range. Must be 1-${state.pageCount}');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final pages = List.generate(end - start + 1, (i) => start + i);
      final extractedData = await _pdfService.extractPages(
        state.filePath!,
        pages,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'split_pages_${start}_to_$end.pdf',
      );

      if (outputPath != null) {
        await _pdfService.savePdf(extractedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF split successfully!',
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
        error: 'Error splitting PDF: ${e.toString()}',
      );
    }
  }
}

final splitPdfProvider =
    StateNotifierProvider<SplitPdfNotifier, SplitPdfState>((ref) {
  return SplitPdfNotifier(
    ref.watch(pdfManipulationServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
