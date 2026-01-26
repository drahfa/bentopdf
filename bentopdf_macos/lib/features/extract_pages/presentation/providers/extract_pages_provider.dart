import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class ExtractPagesState {
  final String? filePath;
  final pdfx.PdfDocument? document;
  final int? pageCount;
  final Set<int> selectedPages;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const ExtractPagesState({
    this.filePath,
    this.document,
    this.pageCount,
    this.selectedPages = const {},
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  ExtractPagesState copyWith({
    String? filePath,
    pdfx.PdfDocument? document,
    int? pageCount,
    Set<int>? selectedPages,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return ExtractPagesState(
      filePath: filePath ?? this.filePath,
      document: document ?? this.document,
      pageCount: pageCount ?? this.pageCount,
      selectedPages: selectedPages ?? this.selectedPages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ExtractPagesNotifier extends StateNotifier<ExtractPagesState> {
  final PdfManipulationService _pdfService;
  final FileService _fileService;

  ExtractPagesNotifier(this._pdfService, this._fileService)
      : super(const ExtractPagesState());

  Future<void> selectFile() async {
    final filePath = await _fileService.pickPdfFile();
    if (filePath == null) return;

    try {
      // Load PDF document
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = await pdfx.PdfDocument.openData(bytes);

      final pageCount = document.pagesCount;
      state = state.copyWith(
        filePath: filePath,
        document: document,
        pageCount: pageCount,
        selectedPages: {},
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error loading PDF: ${e.toString()}');
    }
  }

  void togglePage(int pageNumber) {
    final selected = Set<int>.from(state.selectedPages);
    if (selected.contains(pageNumber)) {
      selected.remove(pageNumber);
    } else {
      selected.add(pageNumber);
    }
    state = state.copyWith(selectedPages: selected, error: null);
  }

  void selectAll() {
    if (state.pageCount == null) return;
    final all = Set<int>.from(List.generate(state.pageCount!, (i) => i + 1));
    state = state.copyWith(selectedPages: all);
  }

  void clearSelection() {
    state = state.copyWith(selectedPages: {});
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> extractPages() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    if (state.selectedPages.isEmpty) {
      state = state.copyWith(error: 'Please select pages to extract');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final sortedPages = state.selectedPages.toList()..sort();
      final extractedData = await _pdfService.extractPages(
        state.filePath!,
        sortedPages,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'extracted_pages.pdf',
      );

      if (outputPath != null) {
        await _pdfService.savePdf(extractedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'Pages extracted successfully!',
          selectedPages: {},
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
        error: 'Error extracting pages: ${e.toString()}',
      );
    }
  }
}

final extractPagesProvider =
    StateNotifierProvider<ExtractPagesNotifier, ExtractPagesState>((ref) {
  return ExtractPagesNotifier(
    ref.watch(pdfManipulationServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
