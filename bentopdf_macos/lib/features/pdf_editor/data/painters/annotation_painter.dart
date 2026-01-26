import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/models/annotation_base.dart';
import '../../domain/models/highlight_annotation.dart';
import '../../domain/models/ink_annotation.dart';
import '../../domain/models/shape_annotation.dart';
import '../../domain/models/signature_annotation.dart';
import '../../domain/models/stamp_annotation.dart';
import '../../domain/models/comment_annotation.dart';
import '../../domain/models/text_annotation.dart';

class AnnotationPainter extends CustomPainter {
  final List<AnnotationBase> annotations;
  final String? selectedAnnotationId;
  final Map<String, ui.Image>? imageCache;
  final Rect? tempBoundsOverride;

  AnnotationPainter({
    required this.annotations,
    this.selectedAnnotationId,
    this.imageCache,
    this.tempBoundsOverride,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final annotation in annotations) {
      final isSelected = annotation.id == selectedAnnotationId;

      switch (annotation.type) {
        case AnnotationType.highlight:
          _paintHighlight(canvas, annotation as HighlightAnnotation);
          break;
        case AnnotationType.ink:
          _paintInk(canvas, annotation as InkAnnotation);
          break;
        case AnnotationType.rectangle:
        case AnnotationType.circle:
          _paintShape(canvas, annotation as ShapeAnnotation);
          break;
        case AnnotationType.signature:
          _paintSignature(
            canvas,
            annotation as SignatureAnnotation,
            imageCache,
          );
          break;
        case AnnotationType.stamp:
          _paintStamp(canvas, annotation as StampAnnotation, imageCache);
          break;
        case AnnotationType.comment:
          _paintComment(canvas, annotation as CommentAnnotation);
          break;
        case AnnotationType.text:
          _paintText(canvas, annotation as TextAnnotation);
          break;
      }

      if (isSelected) {
        _paintSelectionBorder(canvas, annotation);
      }
    }
  }

  void _paintHighlight(Canvas canvas, HighlightAnnotation annotation) {
    final paint = Paint()
      ..color = annotation.color.withOpacity(annotation.opacity)
      ..style = PaintingStyle.fill;

    canvas.drawRect(annotation.bounds, paint);
  }

  void _paintInk(Canvas canvas, InkAnnotation annotation) {
    if (annotation.points.isEmpty) return;

    final paint = Paint()
      ..color = annotation.color.withOpacity(annotation.opacity)
      ..strokeWidth = annotation.thickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(annotation.points[0].dx, annotation.points[0].dy);

    for (int i = 1; i < annotation.points.length; i++) {
      path.lineTo(annotation.points[i].dx, annotation.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  void _paintShape(Canvas canvas, ShapeAnnotation annotation) {
    final paint = Paint()
      ..color = annotation.color.withOpacity(annotation.opacity)
      ..strokeWidth = annotation.strokeWidth
      ..style =
          annotation.filled ? PaintingStyle.fill : PaintingStyle.stroke;

    if (annotation.shapeType == ShapeType.rectangle) {
      canvas.drawRect(annotation.bounds, paint);
    } else {
      canvas.drawOval(annotation.bounds, paint);
    }
  }

  void _paintSignature(
    Canvas canvas,
    SignatureAnnotation annotation,
    Map<String, ui.Image>? imageCache,
  ) {
    final image = imageCache?[annotation.id];
    if (image != null) {
      final bounds = (tempBoundsOverride != null &&
                      annotation.id == selectedAnnotationId)
          ? tempBoundsOverride!
          : annotation.bounds;

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        bounds,
        Paint(),
      );
    }
  }

  void _paintStamp(
    Canvas canvas,
    StampAnnotation annotation,
    Map<String, ui.Image>? imageCache,
  ) {
    final image = imageCache?[annotation.id];
    if (image != null) {
      final bounds = (tempBoundsOverride != null &&
                      annotation.id == selectedAnnotationId)
          ? tempBoundsOverride!
          : annotation.bounds;

      final paint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, annotation.opacity)
        ..filterQuality = FilterQuality.high;

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        bounds,
        paint,
      );
    }
  }

  void _paintComment(Canvas canvas, CommentAnnotation annotation) {
    const iconSize = 24.0;
    final iconRect = Rect.fromLTWH(
      annotation.position.dx - iconSize / 2,
      annotation.position.dy - iconSize / 2,
      iconSize,
      iconSize,
    );

    final paint = Paint()
      ..color = annotation.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(annotation.position.dx, annotation.position.dy),
      iconSize / 2,
      paint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '💬',
        style: TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        iconRect.left + (iconRect.width - textPainter.width) / 2,
        iconRect.top + (iconRect.height - textPainter.height) / 2,
      ),
    );
  }

  void _paintText(Canvas canvas, TextAnnotation annotation) {
    final textSpan = TextSpan(
      text: annotation.text,
      style: TextStyle(
        color: annotation.color,
        fontSize: annotation.fontSize,
        fontWeight: annotation.fontWeight,
        fontFamily: annotation.fontFamily,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, annotation.position);
  }

  void _paintSelectionBorder(Canvas canvas, AnnotationBase annotation) {
    Rect bounds;

    if (annotation is HighlightAnnotation) {
      bounds = annotation.bounds;
    } else if (annotation is ShapeAnnotation) {
      bounds = annotation.bounds;
    } else if (annotation is SignatureAnnotation) {
      bounds = annotation.bounds;
    } else if (annotation is StampAnnotation) {
      bounds = annotation.bounds;
    } else if (annotation is CommentAnnotation) {
      bounds = Rect.fromCircle(center: annotation.position, radius: 12);
    } else if (annotation is TextAnnotation) {
      final textSpan = TextSpan(
        text: annotation.text,
        style: TextStyle(
          fontSize: annotation.fontSize,
          fontWeight: annotation.fontWeight,
          fontFamily: annotation.fontFamily,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      bounds = Rect.fromLTWH(
        annotation.position.dx,
        annotation.position.dy,
        textPainter.width,
        textPainter.height,
      );
    } else if (annotation is InkAnnotation) {
      if (annotation.points.isEmpty) return;
      double left = annotation.points[0].dx;
      double top = annotation.points[0].dy;
      double right = annotation.points[0].dx;
      double bottom = annotation.points[0].dy;

      for (final point in annotation.points) {
        left = point.dx < left ? point.dx : left;
        top = point.dy < top ? point.dy : top;
        right = point.dx > right ? point.dx : right;
        bottom = point.dy > bottom ? point.dy : bottom;
      }

      bounds = Rect.fromLTRB(left, top, right, bottom).inflate(5);
    } else {
      return;
    }

    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(bounds, borderPaint);

    const handleSize = 8.0;
    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final handles = [
      bounds.topLeft,
      bounds.topCenter,
      bounds.topRight,
      bounds.centerLeft,
      bounds.centerRight,
      bounds.bottomLeft,
      bounds.bottomCenter,
      bounds.bottomRight,
    ];

    for (final handle in handles) {
      canvas.drawCircle(handle, handleSize / 2, handlePaint);
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) {
    return annotations != oldDelegate.annotations ||
        selectedAnnotationId != oldDelegate.selectedAnnotationId ||
        imageCache != oldDelegate.imageCache ||
        tempBoundsOverride != oldDelegate.tempBoundsOverride;
  }
}
