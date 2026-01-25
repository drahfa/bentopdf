import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/core/di/service_providers.dart';
import 'package:pdfcow/shared/services/image_conversion_service.dart';
import 'package:pdfcow/shared/services/file_service.dart';
import 'package:path/path.dart' as path;

class ImageInfo {
  final String path;
  final String name;

  const ImageInfo({
    required this.path,
    required this.name,
  });
}

class ImagesToPdfState {
  final List<ImageInfo> images;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const ImagesToPdfState({
    this.images = const [],
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  ImagesToPdfState copyWith({
    List<ImageInfo>? images,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return ImagesToPdfState(
      images: images ?? this.images,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ImagesToPdfNotifier extends StateNotifier<ImagesToPdfState> {
  final ImageConversionService _conversionService;
  final FileService _fileService;

  ImagesToPdfNotifier(this._conversionService, this._fileService)
      : super(const ImagesToPdfState());

  Future<void> addImages() async {
    final imagePaths = await _fileService.pickImageFiles();
    if (imagePaths.isEmpty) return;

    final newImages = imagePaths
        .map((p) => ImageInfo(
              path: p,
              name: path.basename(p),
            ))
        .toList();

    state = state.copyWith(
      images: [...state.images, ...newImages],
      error: null,
      successMessage: null,
    );
  }

  void removeImage(int index) {
    final images = List<ImageInfo>.from(state.images);
    images.removeAt(index);
    state = state.copyWith(
      images: images,
      error: null,
      successMessage: null,
    );
  }

  void reorderImages(int oldIndex, int newIndex) {
    final images = List<ImageInfo>.from(state.images);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    state = state.copyWith(images: images);
  }

  void clearImages() {
    state = state.copyWith(
      images: [],
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

  Future<void> createPdf() async {
    if (state.images.isEmpty) {
      state = state.copyWith(error: 'Please add at least one image');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null, successMessage: null);

    try {
      final imagePaths = state.images.map((img) => img.path).toList();
      final pdfData = await _conversionService.convertImagesToPdf(imagePaths);

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'images_to_pdf.pdf',
      );

      if (outputPath != null) {
        await _conversionService.savePdf(pdfData, outputPath);
        state = state.copyWith(
          isProcessing: false,
          successMessage: 'PDF created successfully!',
          images: [],
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
        error: 'Error creating PDF: ${e.toString()}',
      );
    }
  }
}

final imagesToPdfProvider =
    StateNotifierProvider<ImagesToPdfNotifier, ImagesToPdfState>((ref) {
  return ImagesToPdfNotifier(
    ref.watch(imageConversionServiceProvider),
    ref.watch(fileServiceProvider),
  );
});
