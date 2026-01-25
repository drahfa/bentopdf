import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/pdf_security_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';

class EncryptPdfState {
  final String? filePath;
  final String password;
  final String confirmPassword;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const EncryptPdfState({
    this.filePath,
    this.password = '',
    this.confirmPassword = '',
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  EncryptPdfState copyWith({
    String? filePath,
    String? password,
    String? confirmPassword,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return EncryptPdfState(
      filePath: filePath ?? this.filePath,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class EncryptPdfNotifier extends StateNotifier<EncryptPdfState> {
  final PdfSecurityService _securityService;
  final FileService _fileService;

  EncryptPdfNotifier(this._securityService, this._fileService)
      : super(const EncryptPdfState());

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

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> encryptPdf() async {
    if (state.filePath == null) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    if (state.password.isEmpty) {
      state = state.copyWith(error: 'Please enter a password');
      return;
    }

    if (state.password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return;
    }

    if (state.password != state.confirmPassword) {
      state = state.copyWith(error: 'Passwords do not match');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final encryptedData = await _securityService.encryptPdf(
        state.filePath!,
        state.password,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'encrypted.pdf',
      );

      if (outputPath != null) {
        await _securityService.savePdf(encryptedData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF encrypted successfully!',
          password: '',
          confirmPassword: '',
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
        error: 'Error encrypting PDF: ${e.toString()}',
      );
    }
  }
}

final encryptPdfProvider =
    StateNotifierProvider<EncryptPdfNotifier, EncryptPdfState>((ref) {
  return EncryptPdfNotifier(
    ref.watch(pdfSecurityServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
