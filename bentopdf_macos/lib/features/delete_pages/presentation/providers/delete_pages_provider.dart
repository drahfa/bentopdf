import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class DeletePagesState {
  final String? filePath;
  final int? pageCount;
  final Set<int> selectedPages;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const DeletePagesState({
    this.filePath,
    this.pageCount,
    this.selectedPages = const {},
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  DeletePagesState copyWith({
    String? filePath,
    int? pageCount,
    Set<int>? selectedPages,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return DeletePagesState(
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      selectedPages: selectedPages ?? this.selectedPages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
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
      final pageCount = await _pdfService.getPageCount(filePath);
      state = state.copyWith(
        filePath: filePath,
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

  Future<void> deletePages() async {
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
