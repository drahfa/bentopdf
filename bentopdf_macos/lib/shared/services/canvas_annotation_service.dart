import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../features/pdf_editor/domain/models/annotation_base.dart';
import '../../features/pdf_editor/data/painters/annotation_painter.dart';

enum AnnotationTool {
  pan,
  none,
  highlight,
  ink,
  signature,
  stamp,
  comment,
  rectangle,
  circle,
}

class CanvasAnnotationService {
  final Map<int, List<AnnotationBase>> _annotationsByPage = {};
  List<Offset> _currentDrawingPoints = [];
  Offset? _drawingStartPoint;

  List<AnnotationBase> getAnnotationsForPage(int pageNumber) {
    return _annotationsByPage[pageNumber] ?? [];
  }

  Map<int, List<AnnotationBase>> getAllAnnotations() {
    return Map.from(_annotationsByPage);
  }

  void addAnnotation(int pageNumber, AnnotationBase annotation) {
    _annotationsByPage.putIfAbsent(pageNumber, () => []);
    _annotationsByPage[pageNumber]!.add(annotation);
  }

  void removeAnnotation(int pageNumber, String annotationId) {
    final annotations = _annotationsByPage[pageNumber];
    if (annotations != null) {
      annotations.removeWhere((a) => a.id == annotationId);
      if (annotations.isEmpty) {
        _annotationsByPage.remove(pageNumber);
      }
    }
  }

  void clearAnnotationsForPage(int pageNumber) {
    _annotationsByPage.remove(pageNumber);
  }

  void clearAllAnnotations() {
    _annotationsByPage.clear();
  }

  void startDrawing(Offset position, AnnotationTool tool) {
    if (tool == AnnotationTool.ink) {
      _currentDrawingPoints = [position];
    } else if (tool == AnnotationTool.highlight ||
        tool == AnnotationTool.rectangle ||
        tool == AnnotationTool.circle) {
      _drawingStartPoint = position;
    }
  }

  void continueDrawing(Offset position, AnnotationTool tool) {
    if (tool == AnnotationTool.ink) {
      _currentDrawingPoints.add(position);
    }
  }

  List<Offset> getCurrentDrawingPoints() {
    return List.from(_currentDrawingPoints);
  }

  Rect? getCurrentDrawingRect(Offset currentPosition) {
    if (_drawingStartPoint == null) return null;

    return Rect.fromPoints(_drawingStartPoint!, currentPosition);
  }

  void endDrawing() {
    _currentDrawingPoints.clear();
    _drawingStartPoint = null;
  }

  Future<Uint8List?> exportAnnotationsToImage(
    int pageNumber,
    Size pageSize,
  ) async {
    final annotations = getAnnotationsForPage(pageNumber);
    if (annotations.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final painter = AnnotationPainter(
      annotations: annotations,
    );

    painter.paint(canvas, pageSize);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      pageSize.width.toInt(),
      pageSize.height.toInt(),
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData?.buffer.asUint8List();
  }

  AnnotationBase? findAnnotationAt(
    int pageNumber,
    Offset position,
  ) {
    final annotations = getAnnotationsForPage(pageNumber);

    for (final annotation in annotations.reversed) {
      if (_isPointInAnnotation(annotation, position)) {
        return annotation;
      }
    }

    return null;
  }

  bool _isPointInAnnotation(AnnotationBase annotation, Offset position) {
    if (annotation.type == AnnotationType.highlight ||
        annotation.type == AnnotationType.rectangle ||
        annotation.type == AnnotationType.circle ||
        annotation.type == AnnotationType.signature ||
        annotation.type == AnnotationType.stamp) {
      final bounds = _getBounds(annotation);
      return bounds?.contains(position) ?? false;
    } else if (annotation.type == AnnotationType.comment) {
      final commentAnnotation =
          annotation as dynamic;
      final distance = (commentAnnotation.position - position).distance;
      return distance <= 12;
    } else if (annotation.type == AnnotationType.ink) {
      final inkAnnotation = annotation as dynamic;
      for (final point in inkAnnotation.points) {
        if ((point - position).distance <= inkAnnotation.thickness * 2) {
          return true;
        }
      }
      return false;
    }

    return false;
  }

  Rect? _getBounds(AnnotationBase annotation) {
    try {
      return (annotation as dynamic).bounds as Rect?;
    } catch (e) {
      return null;
    }
  }
}
