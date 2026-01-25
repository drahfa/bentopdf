import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/features/merge_pdf/domain/models/pdf_file_info.dart';
import 'package:pdfcow/shared/services/pdf_manipulation_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';
import 'package:path/path.dart' as path;

class MergePdfState {
  final List<PdfFileInfo> files;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const MergePdfState({
    this.files = const [],
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  MergePdfState copyWith({
    List<PdfFileInfo>? files,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return MergePdfState(
      files: files ?? this.files,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class MergePdfNotifier extends StateNotifier<MergePdfState> {
  final PdfManipulationService _pdfService;
  final FileService _fileService;

  MergePdfNotifier(this._pdfService, this._fileService)
      : super(const MergePdfState());

  Future<void> addFiles() async {
    final filePaths = await _fileService.pickMultiplePdfFiles();
    if (filePaths.isEmpty) return;

    final newFiles = <PdfFileInfo>[];
    for (final filePath in filePaths) {
      try {
        final pageCount = await _pdfService.getPageCount(filePath);
        newFiles.add(PdfFileInfo(
          path: filePath,
          name: path.basename(filePath),
          pageCount: pageCount,
        ));
      } catch (e) {
        newFiles.add(PdfFileInfo(
          path: filePath,
          name: path.basename(filePath),
        ));
      }
    }

    state = state.copyWith(
      files: [...state.files, ...newFiles],
      error: null,
      successMessage: null,
    );
  }

  void removeFile(int index) {
    final files = List<PdfFileInfo>.from(state.files);
    files.removeAt(index);
    state = state.copyWith(
      files: files,
      error: null,
      successMessage: null,
    );
  }

  void reorderFiles(int oldIndex, int newIndex) {
    final files = List<PdfFileInfo>.from(state.files);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = files.removeAt(oldIndex);
    files.insert(newIndex, item);
    state = state.copyWith(files: files);
  }

  void clearFiles() {
    state = state.copyWith(
      files: [],
      error: null,
      successMessage: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> mergePdfs() async {
    if (state.files.length < 2) {
      state = state.copyWith(error: 'Please add at least 2 PDF files');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null, successMessage: null);

    try {
      final filePaths = state.files.map((f) => f.path).toList();
      final mergedData = await _pdfService.mergePdfs(filePaths);

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'merged.pdf',
      );

      if (outputPath != null) {
        await _pdfService.savePdf(mergedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF merged successfully!',
          files: [],
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
        error: 'Error merging PDFs: ${e.toString()}',
      );
    }
  }
}

final mergePdfProvider =
    StateNotifierProvider<MergePdfNotifier, MergePdfState>((ref) {
  return MergePdfNotifier(
    ref.watch(pdfManipulationServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
