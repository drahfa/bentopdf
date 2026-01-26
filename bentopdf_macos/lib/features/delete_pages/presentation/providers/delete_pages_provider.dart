import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class DeletePagesState {
  final String? filePath;
  final pdfx.PdfDocument? document;
  final int? pageCount;
  final Set<int> selectedPages;
  final bool isProcessing;
  final String? error;
  final String? successMessage;
  final bool previewMode;
  final List<int>? remainingPages;

  const DeletePagesState({
    this.filePath,
    this.document,
    this.pageCount,
    this.selectedPages = const {},
    this.isProcessing = false,
    this.error,
    this.successMessage,
    this.previewMode = false,
    this.remainingPages,
  });

  DeletePagesState copyWith({
    String? filePath,
    pdfx.PdfDocument? document,
    int? pageCount,
    Set<int>? selectedPages,
    bool? isProcessing,
    String? error,
    String? successMessage,
    bool? previewMode,
    List<int>? remainingPages,
  }) {
    return DeletePagesState(
      filePath: filePath ?? this.filePath,
      document: document ?? this.document,
      pageCount: pageCount ?? this.pageCount,
      selectedPages: selectedPages ?? this.selectedPages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
      previewMode: previewMode ?? this.previewMode,
      remainingPages: remainingPages ?? this.remainingPages,
    );
  }
}

class DeletePagesNotifier extends StateNotifier<DeletePagesState> {
  final PdfManipulationService _pdfService;
  final FileService _fileService;

  DeletePagesNotifier(this._pdfService, this._fileService)
      : super(const DeletePagesState());

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

  void deletePages() {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    if (state.selectedPages.isEmpty) {
      state = state.copyWith(error: 'Please select pages to delete');
      return;
    }

    if (state.selectedPages.length >= (state.pageCount ?? 0)) {
      state = state.copyWith(error: 'Cannot delete all pages');
      return;
    }

    // Calculate remaining pages
    final allPages = List.generate(state.pageCount!, (i) => i + 1);
    final remaining = allPages.where((p) => !state.selectedPages.contains(p)).toList();

    // Enter preview mode
    state = state.copyWith(
      previewMode: true,
      remainingPages: remaining,
      error: null,
    );
  }

  void cancelPreview() {
    state = state.copyWith(
      previewMode: false,
      remainingPages: null,
    );
  }

  Future<void> savePdf() async {
    if (state.filePath == null || !state.previewMode) {
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final deletedData = await _pdfService.deletePages(
        state.filePath!,
        state.selectedPages.toList(),
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'deleted_pages.pdf',
      );

      if (outputPath != null) {
        await _pdfService.savePdf(deletedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'Pages deleted successfully!',
          selectedPages: {},
          previewMode: false,
          remainingPages: null,
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
        error: 'Error deleting pages: ${e.toString()}',
      );
    }
  }
}

final deletePagesProvider =
    StateNotifierProvider<DeletePagesNotifier, DeletePagesState>((ref) {
  return DeletePagesNotifier(
    ref.watch(pdfManipulationServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
