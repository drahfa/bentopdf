import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class PageItem {
  final int originalPageNumber;
  final String id;

  PageItem({
    required this.originalPageNumber,
    required this.id,
  });

  PageItem copyWith({
    int? originalPageNumber,
    String? id,
  }) {
    return PageItem(
      originalPageNumber: originalPageNumber ?? this.originalPageNumber,
      id: id ?? this.id,
    );
  }
}

class OrganizePdfState {
  final String? filePath;
  final int? pageCount;
  final List<PageItem> pages;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const OrganizePdfState({
    this.filePath,
    this.pageCount,
    this.pages = const [],
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  OrganizePdfState copyWith({
    String? filePath,
    int? pageCount,
    List<PageItem>? pages,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return OrganizePdfState(
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      pages: pages ?? this.pages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class OrganizePdfNotifier extends StateNotifier<OrganizePdfState> {
  final PdfManipulationService _pdfService;
  final FileService _fileService;

  OrganizePdfNotifier(this._pdfService, this._fileService)
      : super(const OrganizePdfState());

  Future<void> selectFile() async {
    final filePath = await _fileService.pickPdfFile();
    if (filePath == null) return;

    try {
      final pageCount = await _pdfService.getPageCount(filePath);
      final pages = List.generate(
        pageCount,
        (i) => PageItem(
          originalPageNumber: i + 1,
          id: '${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      state = state.copyWith(
        filePath: filePath,
        pageCount: pageCount,
        pages: pages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error loading PDF: ${e.toString()}');
    }
  }

  void reorderPages(int oldIndex, int newIndex) {
    final pages = List<PageItem>.from(state.pages);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = pages.removeAt(oldIndex);
    pages.insert(newIndex, item);
    state = state.copyWith(pages: pages);
  }

  void duplicatePage(int index) {
    final pages = List<PageItem>.from(state.pages);
    final pageToDuplicate = pages[index];
    final duplicated = PageItem(
      originalPageNumber: pageToDuplicate.originalPageNumber,
      id: '${pageToDuplicate.originalPageNumber}_${DateTime.now().millisecondsSinceEpoch}',
    );
    pages.insert(index + 1, duplicated);
    state = state.copyWith(pages: pages);
  }

  void deletePage(int index) {
    final pages = List<PageItem>.from(state.pages);
    if (pages.length <= 1) {
      state = state.copyWith(error: 'Cannot delete all pages');
      return;
    }
    pages.removeAt(index);
    state = state.copyWith(pages: pages);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> savePdf() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    if (state.pages.isEmpty) {
      state = state.copyWith(error: 'No pages to save');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final pageNumbers = state.pages.map((p) => p.originalPageNumber).toList();
      final organizedData = await _pdfService.extractPages(
        state.filePath!,
        pageNumbers,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'organized.pdf',
      );

      if (outputPath != null) {
        await _pdfService.savePdf(organizedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF organized successfully!',
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
        error: 'Error organizing PDF: ${e.toString()}',
      );
    }
  }
}

final organizePdfProvider =
    StateNotifierProvider<OrganizePdfNotifier, OrganizePdfState>((ref) {
  return OrganizePdfNotifier(
    ref.watch(pdfManipulationServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
