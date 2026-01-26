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
import '../../domain/models/text_annotation.dart';
import '../../../../shared/services/canvas_annotation_service.dart';
import '../../../../shared/services/pdf_export_service.dart';
import '../../../../shared/services/pdf_manipulation_service.dart';
import '../../../../shared/services/pdf_metadata_service.dart';
import '../../../../shared/services/file_service.dart';
import '../../../../core/di/service_providers.dart';

enum PageOrientation {
  portrait,
  landscape,
  square,
}

class PageOrientationInfo {
  final int pageNumber;
  final PageOrientation orientation;
  final double width;
  final double height;
  final int rotation; // Rotation in degrees (0, 90, 180, 270)

  const PageOrientationInfo({
    required this.pageNumber,
    required this.orientation,
    required this.width,
    required this.height,
    this.rotation = 0,
  });

  static PageOrientation detectOrientation(double width, double height, int rotation) {
    // Account for rotation: if rotated 90 or 270 degrees, swap width/height
    final effectiveWidth = (rotation == 90 || rotation == 270) ? height : width;
    final effectiveHeight = (rotation == 90 || rotation == 270) ? width : height;

    if ((effectiveWidth - effectiveHeight).abs() < 1.0) {
      return PageOrientation.square;
    } else if (effectiveWidth > effectiveHeight) {
      return PageOrientation.landscape;
    } else {
      return PageOrientation.portrait;
    }
  }

  String get orientationName {
    switch (orientation) {
      case PageOrientation.portrait:
        return 'Portrait';
      case PageOrientation.landscape:
        return 'Landscape';
      case PageOrientation.square:
        return 'Square';
    }
  }

  // Get actual display dimensions after applying rotation
  double get displayWidth => (rotation == 90 || rotation == 270) ? height : width;
  double get displayHeight => (rotation == 90 || rotation == 270) ? width : height;
}

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
  final AnnotationBase? copiedAnnotation;
  final List<PageOrientationInfo> pageOrientations;
  final bool hasMixedOrientations;

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
    this.opacity = 0.3,
    this.zoomLevel = 0.5,
    this.currentPageAnnotations = const [],
    this.selectedAnnotationId,
    this.isProcessing = false,
    this.error,
    this.successMessage,
    this.showCommentSidebar = false,
    this.exportProgress = 0.0,
    this.imageCache = const {},
    this.copiedAnnotation,
    this.pageOrientations = const [],
    this.hasMixedOrientations = false,
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
    AnnotationBase? copiedAnnotation,
    List<PageOrientationInfo>? pageOrientations,
    bool? hasMixedOrientations,
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
      copiedAnnotation: copiedAnnotation ?? this.copiedAnnotation,
      pageOrientations: pageOrientations ?? this.pageOrientations,
      hasMixedOrientations: hasMixedOrientations ?? this.hasMixedOrientations,
    );
  }
}

class PdfEditorNotifier extends StateNotifier<PdfEditorState> {
  final CanvasAnnotationService _annotationService;
  final PdfExportService _exportService;
  final PdfManipulationService _manipulationService;
  final PdfMetadataService _metadataService;
  final FileService _fileService;
  final Random _random = Random();

  PdfEditorNotifier({
    required CanvasAnnotationService annotationService,
    required PdfExportService exportService,
    required PdfManipulationService manipulationService,
    required PdfMetadataService metadataService,
    required FileService fileService,
  })  : _annotationService = annotationService,
        _exportService = exportService,
        _manipulationService = manipulationService,
        _metadataService = metadataService,
        _fileService = fileService,
        super(const PdfEditorState());

  Future<void> loadPdf(String filePath) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = await pdfx.PdfDocument.openData(bytes);

      // Get rotation information for pages
      final rotation = await _metadataService.getPageRotation(filePath, 1);

      // Detect orientations for all pages
      final List<PageOrientationInfo> orientations = [];
      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);

        final orientation = PageOrientationInfo.detectOrientation(
          page.width,
          page.height,
          rotation,
        );

        orientations.add(PageOrientationInfo(
          pageNumber: i,
          orientation: orientation,
          width: page.width,
          height: page.height,
          rotation: rotation,
        ));
        await page.close();
      }

      // Determine if mixed orientations exist
      final uniqueOrientations = orientations
          .map((o) => o.orientation)
          .toSet();
      final hasMixed = uniqueOrientations.length > 1;

      state = state.copyWith(
        filePath: filePath,
        document: document,
        totalPages: document.pagesCount,
        currentPageNumber: 1,
        pageOrientations: orientations,
        hasMixedOrientations: hasMixed,
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

      // Get rotation for this page
      final pageOrientation = state.pageOrientations
          .where((o) => o.pageNumber == pageNumber)
          .firstOrNull;
      final rotation = pageOrientation?.rotation ?? 0;

      // Calculate display dimensions accounting for rotation
      final displayWidth = pageOrientation?.displayWidth ?? page.width;
      final displayHeight = pageOrientation?.displayHeight ?? page.height;

      // Render with swapped dimensions if rotated 90 or 270 degrees
      final renderWidth = (rotation == 90 || rotation == 270) ? page.height * 2 : page.width * 2;
      final renderHeight = (rotation == 90 || rotation == 270) ? page.width * 2 : page.height * 2;

      final pageImage = await page.render(
        width: renderWidth,
        height: renderHeight,
        format: pdfx.PdfPageImageFormat.png,
      );

      final annotations =
          _annotationService.getAnnotationsForPage(pageNumber);

      state = state.copyWith(
        currentPageNumber: pageNumber,
        currentPageImage: pageImage,
        currentPageAnnotations: annotations,
        selectedAnnotationId: null,
        currentPageWidth: displayWidth,
        currentPageHeight: displayHeight,
      );

      await page.close();

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
      opacity: 1.0, // Always fully opaque for stamps
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
    } else if (annotation is HighlightAnnotation) {
      updatedAnnotation = HighlightAnnotation(
        id: annotation.id,
        pageNumber: annotation.pageNumber,
        createdAt: annotation.createdAt,
        bounds: newBounds,
        color: annotation.color,
        opacity: annotation.opacity,
      );
    } else if (annotation is ShapeAnnotation) {
      updatedAnnotation = ShapeAnnotation(
        id: annotation.id,
        pageNumber: annotation.pageNumber,
        createdAt: annotation.createdAt,
        shapeType: annotation.shapeType,
        bounds: newBounds,
        color: annotation.color,
        strokeWidth: annotation.strokeWidth,
        opacity: annotation.opacity,
        filled: annotation.filled,
      );
    } else if (annotation is InkAnnotation) {
      // Calculate old bounds
      final oldPoints = annotation.points;
      if (oldPoints.isEmpty) return;

      double minX = oldPoints.first.dx;
      double minY = oldPoints.first.dy;
      double maxX = oldPoints.first.dx;
      double maxY = oldPoints.first.dy;

      for (final point in oldPoints) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }

      final padding = annotation.thickness / 2;
      final oldBounds = Rect.fromLTRB(
        minX - padding,
        minY - padding,
        maxX + padding,
        maxY + padding,
      );

      // Calculate delta and translate all points
      final deltaX = newBounds.left - oldBounds.left;
      final deltaY = newBounds.top - oldBounds.top;

      final translatedPoints = oldPoints
          .map((point) => Offset(point.dx + deltaX, point.dy + deltaY))
          .toList();

      updatedAnnotation = InkAnnotation(
        id: annotation.id,
        pageNumber: annotation.pageNumber,
        createdAt: annotation.createdAt,
        points: translatedPoints,
        color: annotation.color,
        thickness: annotation.thickness,
        opacity: annotation.opacity,
      );
    } else if (annotation is TextAnnotation) {
      // Update text position based on new bounds
      updatedAnnotation = TextAnnotation(
        id: annotation.id,
        pageNumber: annotation.pageNumber,
        createdAt: annotation.createdAt,
        text: annotation.text,
        position: newBounds.topLeft,
        color: annotation.color,
        fontSize: annotation.fontSize,
        fontWeight: annotation.fontWeight,
        fontFamily: annotation.fontFamily,
      );
    } else {
      return;
    }

    _annotationService.addAnnotation(state.currentPageNumber, updatedAnnotation);

    // Refresh annotations while maintaining selection
    final refreshedAnnotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    state = state.copyWith(
      currentPageAnnotations: refreshedAnnotations,
      selectedAnnotationId: annotationId, // Explicitly maintain selection
    );
  }

  void _refreshAnnotations() {
    final annotations =
        _annotationService.getAnnotationsForPage(state.currentPageNumber);
    state = state.copyWith(currentPageAnnotations: annotations);
  }

  List<AnnotationBase> getAnnotationsForPage(int pageNumber) {
    return _annotationService.getAnnotationsForPage(pageNumber);
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
      opacity: 1.0, // Always fully opaque for stamps
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

  void startTextPlacement(
    String text,
    double fontSize,
    Color color,
    FontWeight fontWeight,
  ) {
    if (state.currentPageImage == null) return;

    final pageWidth = (state.currentPageImage!.width ?? 0).toDouble();
    final pageHeight = (state.currentPageImage!.height ?? 0).toDouble();

    // Place text in center of page
    final centerX = pageWidth * 0.4;
    final centerY = pageHeight * 0.4;

    final id = _generateId();
    final annotation = TextAnnotation(
      id: id,
      pageNumber: state.currentPageNumber,
      createdAt: DateTime.now(),
      text: text,
      position: Offset(centerX, centerY),
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    _annotationService.addAnnotation(state.currentPageNumber, annotation);
    _refreshAnnotations();

    state = state.copyWith(
      selectedAnnotationId: id,
      selectedTool: AnnotationTool.none,
    );
  }

  void updateTextAnnotation(
    String annotationId,
    String text,
    double fontSize,
    Color color,
    FontWeight fontWeight,
  ) {
    final annotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    final annotation = annotations.where((a) => a.id == annotationId).firstOrNull;

    if (annotation is! TextAnnotation) return;

    _annotationService.removeAnnotation(state.currentPageNumber, annotationId);

    final updatedAnnotation = TextAnnotation(
      id: annotation.id,
      pageNumber: annotation.pageNumber,
      createdAt: annotation.createdAt,
      text: text,
      position: annotation.position,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: annotation.fontFamily,
    );

    _annotationService.addAnnotation(state.currentPageNumber, updatedAnnotation);

    // Refresh annotations while maintaining selection
    final refreshedAnnotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    state = state.copyWith(
      currentPageAnnotations: refreshedAnnotations,
      selectedAnnotationId: annotationId, // Explicitly maintain selection
    );
  }

  void updateHighlightAnnotation(
    String annotationId,
    Color color,
    double opacity,
  ) {
    final annotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    final annotation = annotations.where((a) => a.id == annotationId).firstOrNull;

    if (annotation is! HighlightAnnotation) return;

    _annotationService.removeAnnotation(state.currentPageNumber, annotationId);

    final updatedAnnotation = HighlightAnnotation(
      id: annotation.id,
      pageNumber: annotation.pageNumber,
      createdAt: annotation.createdAt,
      bounds: annotation.bounds,
      color: color,
      opacity: opacity,
    );

    _annotationService.addAnnotation(state.currentPageNumber, updatedAnnotation);

    // Refresh annotations while maintaining selection
    final refreshedAnnotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    state = state.copyWith(
      currentPageAnnotations: refreshedAnnotations,
      selectedAnnotationId: annotationId, // Explicitly maintain selection
    );
  }

  void copyAnnotation() {
    final selectedId = state.selectedAnnotationId;
    if (selectedId == null) return;

    final annotations = _annotationService.getAnnotationsForPage(state.currentPageNumber);
    final annotation = annotations.where((a) => a.id == selectedId).firstOrNull;

    if (annotation != null) {
      state = state.copyWith(copiedAnnotation: annotation);
    }
  }

  Future<void> pasteAnnotation() async {
    final copiedAnnotation = state.copiedAnnotation;
    if (copiedAnnotation == null) return;

    final id = _generateId();
    final offsetX = 20.0;
    final offsetY = 20.0;

    AnnotationBase newAnnotation;

    if (copiedAnnotation is TextAnnotation) {
      newAnnotation = TextAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        text: copiedAnnotation.text,
        position: Offset(
          copiedAnnotation.position.dx + offsetX,
          copiedAnnotation.position.dy + offsetY,
        ),
        color: copiedAnnotation.color,
        fontSize: copiedAnnotation.fontSize,
        fontWeight: copiedAnnotation.fontWeight,
        fontFamily: copiedAnnotation.fontFamily,
      );
    } else if (copiedAnnotation is HighlightAnnotation) {
      newAnnotation = HighlightAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        bounds: Rect.fromLTWH(
          copiedAnnotation.bounds.left + offsetX,
          copiedAnnotation.bounds.top + offsetY,
          copiedAnnotation.bounds.width,
          copiedAnnotation.bounds.height,
        ),
        color: copiedAnnotation.color,
        opacity: copiedAnnotation.opacity,
      );
    } else if (copiedAnnotation is InkAnnotation) {
      final translatedPoints = copiedAnnotation.points
          .map((point) => Offset(point.dx + offsetX, point.dy + offsetY))
          .toList();
      newAnnotation = InkAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        points: translatedPoints,
        color: copiedAnnotation.color,
        thickness: copiedAnnotation.thickness,
        opacity: copiedAnnotation.opacity,
      );
    } else if (copiedAnnotation is SignatureAnnotation) {
      newAnnotation = SignatureAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        imageData: copiedAnnotation.imageData,
        bounds: Rect.fromLTWH(
          copiedAnnotation.bounds.left + offsetX,
          copiedAnnotation.bounds.top + offsetY,
          copiedAnnotation.bounds.width,
          copiedAnnotation.bounds.height,
        ),
      );
      await _loadImageForAnnotation(id, copiedAnnotation.imageData);
    } else if (copiedAnnotation is StampAnnotation) {
      newAnnotation = StampAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        imageData: copiedAnnotation.imageData,
        bounds: Rect.fromLTWH(
          copiedAnnotation.bounds.left + offsetX,
          copiedAnnotation.bounds.top + offsetY,
          copiedAnnotation.bounds.width,
          copiedAnnotation.bounds.height,
        ),
        opacity: 1.0, // Always fully opaque for stamps
      );
      await _loadImageForAnnotation(id, copiedAnnotation.imageData);
    } else if (copiedAnnotation is ShapeAnnotation) {
      newAnnotation = ShapeAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        shapeType: copiedAnnotation.shapeType,
        bounds: Rect.fromLTWH(
          copiedAnnotation.bounds.left + offsetX,
          copiedAnnotation.bounds.top + offsetY,
          copiedAnnotation.bounds.width,
          copiedAnnotation.bounds.height,
        ),
        color: copiedAnnotation.color,
        strokeWidth: copiedAnnotation.strokeWidth,
        opacity: copiedAnnotation.opacity,
        filled: copiedAnnotation.filled,
      );
    } else if (copiedAnnotation is CommentAnnotation) {
      newAnnotation = CommentAnnotation(
        id: id,
        pageNumber: state.currentPageNumber,
        createdAt: DateTime.now(),
        text: copiedAnnotation.text,
        position: Offset(
          copiedAnnotation.position.dx + offsetX,
          copiedAnnotation.position.dy + offsetY,
        ),
        color: copiedAnnotation.color,
      );
    } else {
      return;
    }

    _annotationService.addAnnotation(state.currentPageNumber, newAnnotation);
    _refreshAnnotations();

    state = state.copyWith(selectedAnnotationId: id);
  }

  Future<void> deletePage(int pageNumber) async {
    try {
      final filePath = state.filePath;
      if (filePath == null || state.document == null) return;

      // Can't delete if only one page left
      if (state.totalPages <= 1) {
        state = state.copyWith(
          error: 'Cannot delete the last page',
        );
        return;
      }

      state = state.copyWith(isProcessing: true, error: null);

      // Delete the page using manipulation service
      final newPdfBytes = await _manipulationService.deletePages(
        filePath,
        [pageNumber],
      );

      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_edited_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(newPdfBytes);

      // Close current document
      await state.document?.close();

      // Clear annotations for all pages
      _annotationService.clearAllAnnotations();

      // Reload the PDF from temp file
      final document = await pdfx.PdfDocument.openData(newPdfBytes);

      state = state.copyWith(
        filePath: tempFile.path,
        document: document,
        totalPages: document.pagesCount,
        currentPageNumber: pageNumber > document.pagesCount ? document.pagesCount : pageNumber,
      );

      await _loadPage(state.currentPageNumber);

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Page deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to delete page: $e',
      );
    }
  }

  Future<void> duplicatePage(int pageNumber) async {
    try {
      final filePath = state.filePath;
      if (filePath == null || state.document == null) return;

      state = state.copyWith(isProcessing: true, error: null);

      // Duplicate the page using manipulation service
      final newPdfBytes = await _manipulationService.duplicatePage(
        filePath,
        pageNumber,
      );

      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_edited_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(newPdfBytes);

      // Close current document
      await state.document?.close();

      // Clear annotations for all pages
      _annotationService.clearAllAnnotations();

      // Reload the PDF from temp file
      final document = await pdfx.PdfDocument.openData(newPdfBytes);

      state = state.copyWith(
        filePath: tempFile.path,
        document: document,
        totalPages: document.pagesCount,
        currentPageNumber: pageNumber + 1, // Go to the duplicated page
      );

      await _loadPage(state.currentPageNumber);

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Page duplicated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to duplicate page: $e',
      );
    }
  }

  Future<void> rotatePage(int pageNumber, int degrees) async {
    try {
      final filePath = state.filePath;
      if (filePath == null || state.document == null) return;

      state = state.copyWith(isProcessing: true, error: null);

      // Rotate the page using manipulation service
      final newPdfBytes = await _manipulationService.rotateSinglePage(
        filePath,
        pageNumber,
        degrees,
      );

      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_edited_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(newPdfBytes);

      // Close current document
      await state.document?.close();

      // Clear annotations for all pages
      _annotationService.clearAllAnnotations();

      // Reload the PDF from temp file
      final document = await pdfx.PdfDocument.openData(newPdfBytes);

      state = state.copyWith(
        filePath: tempFile.path,
        document: document,
        totalPages: document.pagesCount,
        currentPageNumber: pageNumber,
      );

      await _loadPage(state.currentPageNumber);

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Page rotated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to rotate page: $e',
      );
    }
  }

  Future<void> reorderPages(List<int> newOrder) async {
    try {
      final filePath = state.filePath;
      if (filePath == null || state.document == null) return;

      state = state.copyWith(isProcessing: true, error: null);

      // Reorder pages using manipulation service
      final newPdfBytes = await _manipulationService.reorderPages(
        filePath,
        newOrder,
      );

      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_edited_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(newPdfBytes);

      // Close current document
      await state.document?.close();

      // Clear annotations for all pages
      _annotationService.clearAllAnnotations();

      // Reload the PDF from temp file
      final document = await pdfx.PdfDocument.openData(newPdfBytes);

      state = state.copyWith(
        filePath: tempFile.path,
        document: document,
        totalPages: document.pagesCount,
        currentPageNumber: 1,
      );

      await _loadPage(state.currentPageNumber);

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Pages reordered successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to reorder pages: $e',
      );
    }
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
    manipulationService: PdfManipulationService(),
    metadataService: PdfMetadataService(),
    fileService: ref.watch(fileServiceProvider),
  );
});
