import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_security_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class DecryptPdfState {
  final String? filePath;
  final String password;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const DecryptPdfState({
    this.filePath,
    this.password = '',
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  DecryptPdfState copyWith({
    String? filePath,
    String? password,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return DecryptPdfState(
      filePath: filePath ?? this.filePath,
      password: password ?? this.password,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class DecryptPdfNotifier extends StateNotifier<DecryptPdfState> {
  final PdfSecurityService _securityService;
  final FileService _fileService;

  DecryptPdfNotifier(this._securityService, this._fileService)
      : super(const DecryptPdfState());

  Future<void> selectFile() async {
    final filePath = await _fileService.pickPdfFile();
    if (filePath == null) return;

    state = state.copyWith(
      filePath: filePath,
      error: null,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> decryptPdf() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    if (state.password.isEmpty) {
      state = state.copyWith(error: 'Please enter the password');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final decryptedData = await _securityService.decryptPdf(
        state.filePath!,
        state.password,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'decrypted.pdf',
      );

      if (outputPath != null) {
        await _securityService.savePdf(decryptedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF decrypted successfully!',
          password: '',
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
        error: e.toString(),
      );
    }
  }
}

final decryptPdfProvider =
    StateNotifierProvider<DecryptPdfNotifier, DecryptPdfState>((ref) {
  return DecryptPdfNotifier(
    ref.watch(pdfSecurityServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
