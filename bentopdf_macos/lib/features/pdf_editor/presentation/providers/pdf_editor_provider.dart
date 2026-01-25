import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../domain/models/annotation_base.dart';
import '../../domain/models/highlight_annotation.dart';
import '../../domain/models/ink_annotation.dart';
import '../../domain/models/shape_annotation.dart';
import '../../domain/models/signature_annotation.dart';
import '../../domain/models/stamp_annotation.dart';
import '../../domain/models/comment_annotation.dart';
import '../../../../shared/services/canvas_annotation_service.dart';
import '../../../../shared/services/pdf_export_service.dart';
import '../../../../shared/services/file_service.dart';
import '../../../../core/di/service_providers.dart';

class PdfEditorState {
  final String? filePath;
  final pdfx.PdfDocument? document;
  final pdfx.PdfPageImage? currentPageImage;
  final int currentPageNumber;
  final int totalPages;
  final double currentPageWidth;
  final double currentPageHeight;
  final AnnotationTool selectedTool;
  final Color selectedColor;
  final double thickness;
  final double opacity;
  final double zoomLevel;
  final List<AnnotationBase> currentPageAnnotations;
  final String? selectedAnnotationId;
  final bool isProcessing;
  final String? error;
  final String? successMessage;
  final bool showCommentSidebar;
  final double exportProgress;
  final Map<String, ui.Image> imageCache;

  const PdfEditorState({
    this.filePath,
    this.document,
    this.currentPageImage,
    this.currentPageNumber = 1,
    this.totalPages = 0,
    this.currentPageWidth = 0,
    this.currentPageHeight = 0,
    this.selectedTool = AnnotationTool.pan,
    this.selectedColor = Colors.yellow,
    this.thickness = 2.0,
    this.opacity = 1.0,
    this.zoomLevel = 0.5,
    this.currentPageAnnotations = const [],
    this.selectedAnnotationId,
    this.isProcessing = false,
    this.error,
    this.successMessage,
    this.showCommentSidebar = false,
    this.exportProgress = 0.0,
    this.imageCache = const {},
  });

  PdfEditorState copyWith({
    String? filePath,
    pdfx.PdfDocument? document,
    pdfx.PdfPageImage? currentPageImage,
    int? currentPageNumber,
    int? totalPages,
    double? currentPageWidth,
    double? currentPageHeight,
    AnnotationTool? selectedTool,
    Color? selectedColor,
    double? thickness,
    double? opacity,
    double? zoomLevel,
    List<AnnotationBase>? currentPageAnnotations,
    String? selectedAnnotationId,
    bool? isProcessing,
    String? error,
    String? successMessage,
    bool? showCommentSidebar,
    double? exportProgress,
    Map<String, ui.Image>? imageCache,
  }) {
    return PdfEditorState(
      filePath: filePath ?? this.filePath,
      document: document ?? this.document,
      currentPageImage: currentPageImage ?? this.currentPageImage,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      totalPages: totalPages ?? this.totalPages,
      currentPageWidth: currentPageWidth ?? this.currentPageWidth,
      currentPageHeight: currentPageHeight ?? this.currentPageHeight,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedColor: selectedColor ?? this.selectedColor,
      thickness: thickness ?? this.thickness,
      opacity: opacity ?? this.opacity,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      currentPageAnnotations:
          currentPageAnnotations ?? this.currentPageAnnotations,
      selectedAnnotationId: selectedAnnotationId,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
      showCommentSidebar: showCommentSidebar ?? this.showCommentSidebar,
      exportProgress: exportProgress ?? this.exportProgress,
      imageCache: imageCache ?? this.imageCache,
    );
  }
}

class PdfEditorNotifier extends StateNotifier<PdfEditorState> {
  final CanvasAnnotationService _annotationService;
  final PdfExportService _exportService;
  final FileService _fileService;
  final Random _random = Random();

  PdfEditorNotifier({
    required CanvasAnnotationService annotationService,
    required PdfExportService exportService,
    required FileService fileService,
  })  : _annotationService = annotationService,
        _exportService = exportService,
        _fileService = fileService,
        super(const PdfEditorState());

  Future<void> loadPdf(String filePath) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = await pdfx.PdfDocument.openData(bytes);

      state = state.copyWith(
        filePath: filePath,
        document: document,
        totalPages: document.pagesCount,
        currentPageNumber: 1,
      );

      await _loadPage(1);

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to load PDF: $e',
      );
    }
  }

  Future<void> _loadPage(int pageNumber) async {
    try {
      final document = state.document;
      if (document == null) return;

      final page = await document.getPage(pageNumber);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();

      final annotations =
          _annotationService.getAnnotationsForPage(pageNumber);

      state = state.copyWith(
        currentPageNumber: pageNumber,
        currentPageImage: pageImage,
        currentPageAnnotations: annotations,
        selectedAnnotationId: null,
        currentPageWidth: page.width,
        currentPageHeight: page.height,
      );

      await _loadImagesForAnnotations(annotations);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load page: $e');
    }
  }

  Future<void> _loadImagesForAnnotations(
    List<AnnotationBase> annotations,
  ) async {
    for (final annotation in annotations) {
      if (annotation is SignatureAnnotation) {
        if (!state.imageCache.containsKey(annotation.id)) {
          await _loadImageForAnnotation(annotation.id, annotation.imageData);
        }
      } else if (annotation is StampAnnotation) {
        if (!state.imageCache.containsKey(annotation.id)) {
          await _loadImageForAnnotation(annotation.id, annotation.imageData);
        }
      }
    }
  }

  Future<void> goToPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > state.totalPages) return;
    await _loadPage(pageNumber);
  }

  Future<void> nextPage() async {
    if (state.currentPageNumber < state.totalPages) {
      await goToPage(state.currentPageNumber + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.currentPageNumber > 1) {
      await goToPage(state.currentPageNumber - 1);
    }
  }

  void selectTool(AnnotationTool tool) {
    state = state.copyWith(selectedTool: tool, selectedAnnotationId: null);
  }

  void changeColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void changeThickness(double thickness) {
    state = state.copyWith(thickness: thickness);
  }

  void changeOpacity(double opacity) {
    state = state.copyWith(opacity: opacity);
  }

  void changeZoom(double zoom) {
    state = state.copyWith(zoomLevel: zoom);
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  void addHighlightAnnotation(Rect bounds) {
    final annotation = HighlightAnnotation(
      id: _generateId(),
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      bounds: bounds,
      color: state.selectedColor,
      opacity: state.opacity,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _refreshAnnotations();
  }

  void addInkAnnotation(List<Offset> points) {
    if (points.isEmpty) return;

    final annotation = InkAnnotation(
      id: _generateId(),
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      points: points,
      color: state.selectedColor,
      thickness: state.thickness,
      opacity: state.opacity,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _refreshAnnotations();
  }

  void addShapeAnnotation(ShapeType shapeType, Rect bounds) {
    final annotation = ShapeAnnotation(
      id: _generateId(),
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      shapeType: shapeType,
      bounds: bounds,
      color: state.selectedColor,
      strokeWidth: state.thickness,
      opacity: state.opacity,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _refreshAnnotations();
  }

  void addSignatureAnnotation(Uint8List imageData, Rect bounds) {
    final id = _generateId();
    final annotation = SignatureAnnotation(
      id: id,
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      imageData: imageData,
      bounds: bounds,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _loadImageForAnnotation(id, imageData);
    _refreshAnnotations();
  }

  void addStampAnnotation(Uint8List imageData, Rect bounds) {
    final id = _generateId();
    final annotation = StampAnnotation(
      id: id,
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      imageData: imageData,
      bounds: bounds,
      opacity: state.opacity,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _loadImageForAnnotation(id, imageData);
    _refreshAnnotations();
  }

  void addCommentAnnotation(String text, Offset position) {
    final annotation = CommentAnnotation(
      id: _generateId(),
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      text: text,
      position: position,
      color: state.selectedColor,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _refreshAnnotations();
  }

  void selectAnnotation(String? annotationId) {
    state = state.copyWith(selectedAnnotationId: annotationId);
  }

  void deleteSelectedAnnotation() {
    final selectedId = state.selectedAnnotationId;
    if (selectedId != null) {
      _annotationService.removeAnnotation(state.currentPageNumber, selectedId);
      _refreshAnnotations();
      state = state.copyWith(selectedAnnotationId: null);
    }
  }

  void deleteAnnotation(String annotationId) {
    _annotationService.removeAnnotation(state.currentPageNumber, annotationId);
    _refreshAnnotations();
  }

  void updateAnnotationBounds(String annotationId, Rect newBounds) {
    final annotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    final annotation = annotations.where((a) => a.id == annotationId).firstOrNull;

    if (annotation == null) return;

    _annotationService.removeAnnotation(state.currentPageNumber, annotationId);

    AnnotationBase updatedAnnotation;

    if (annotation is StampAnnotation) {
      updatedAnnotation = StampAnnotation(
        id: annotation.id,
        pageNumber: annotation.pageNumber,
        createdAt: annotation.createdAt,
        imageData: annotation.imageData,
        bounds: newBounds,
        opacity: annotation.opacity,
      );
    } else if (annotation is SignatureAnnotation) {
      updatedAnnotation = SignatureAnnotation(
        id: annotation.id,
        pageNumber: annotation.pageNumber,
        createdAt: annotation.createdAt,
        imageData: annotation.imageData,
        bounds: newBounds,
      );
    } else {
      return;
    }

    _annotationService.addAnnotation(state.currentPageNumber, updatedAnnotation);
    _refreshAnnotations();
  }

  void _refreshAnnotations() {
    final annotations =
        _annotationService.getAnnotationsForPage(state.currentPageNumber);
    state = state.copyWith(currentPageAnnotations: annotations);
  }

  Future<void> _loadImageForAnnotation(String id, Uint8List imageData) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final newCache = Map<String, ui.Image>.from(state.imageCache);
      newCache[id] = frame.image;
      state = state.copyWith(imageCache: newCache);
    } catch (e) {
      debugPrint('Failed to load image for annotation $id: $e');
    }
  }

  void toggleCommentSidebar() {
    state = state.copyWith(showCommentSidebar: !state.showCommentSidebar);
  }

  Future<void> startStampPlacement(Uint8List imageData) async {
    if (state.currentPageImage == null) return;

    final pageWidth = (state.currentPageImage!.width ?? 0).toDouble();
    final pageHeight = (state.currentPageImage!.height ?? 0).toDouble();

    // Decode image to get actual dimensions
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final stampImage = frame.image;

    final imageAspectRatio = stampImage.width / stampImage.height;

    // Calculate stamp size maintaining aspect ratio
    final stampWidth = pageWidth * 0.3;
    final stampHeight = stampWidth / imageAspectRatio;

    final centerX = (pageWidth - stampWidth) / 2;
    final centerY = (pageHeight - stampHeight) / 2;

    final bounds = Rect.fromLTWH(centerX, centerY, stampWidth, stampHeight);

    final id = _generateId();
    final annotation = StampAnnotation(
      id: id,
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      imageData: imageData,
      bounds: bounds,
      opacity: state.opacity,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    await _loadImageForAnnotation(id, imageData);
    _refreshAnnotations();

    state = state.copyWith(selectedAnnotationId: id);
  }

  Future<void> startSignaturePlacement(Uint8List imageData) async {
    if (state.currentPageImage == null) return;

    final pageWidth = (state.currentPageImage!.width ?? 0).toDouble();
    final pageHeight = (state.currentPageImage!.height ?? 0).toDouble();

    // Decode image to get actual dimensions
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final signatureImage = frame.image;

    final imageAspectRatio = signatureImage.width / signatureImage.height;

    // Calculate signature size maintaining aspect ratio
    final signatureWidth = pageWidth * 0.3;
    final signatureHeight = signatureWidth / imageAspectRatio;

    final centerX = (pageWidth - signatureWidth) / 2;
    final centerY = (pageHeight - signatureHeight) / 2;

    final bounds = Rect.fromLTWH(centerX, centerY, signatureWidth, signatureHeight);

    final id = _generateId();
    final annotation = SignatureAnnotation(
      id: id,
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      imageData: imageData,
      bounds: bounds,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    await _loadImageForAnnotation(id, imageData);
    _refreshAnnotations();

    state = state.copyWith(selectedAnnotationId: id);
  }

  Future<void> savePdf() async {
    try {
      final filePath = state.filePath;
      if (filePath == null) return;

      state = state.copyWith(
        isProcessing: true,
        error: null,
        exportProgress: 0.0,
      );

      final outputPath = await _fileService.getSaveLocation(
        suggestedName: 'annotated_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (outputPath == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      await _exportService.exportToFile(
        originalPdfPath: filePath,
        outputPath: outputPath,
        annotationsByPage: _annotationService.getAllAnnotations(),
        imageCache: state.imageCache,
        onProgress: (current, total) {
          state = state.copyWith(
            exportProgress: current / total,
          );
        },
      );

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'PDF saved successfully!',
        exportProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to save PDF: $e',
        exportProgress: 0.0,
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(error: null, successMessage: null);
  }

  @override
  void dispose() {
    state.document?.close();
    super.dispose();
  }
}

final pdfEditorProvider =
    StateNotifierProvider.autoDispose<PdfEditorNotifier, PdfEditorState>((ref) {
  return PdfEditorNotifier(
    annotationService: CanvasAnnotationService(),
    exportService: PdfExportService(),
    fileService: ref.watch(fileServiceProvider),
  );
});
