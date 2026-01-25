import 'package:flutter/material.dart';
import '../../domain/models/annotation_base.dart';
import '../../domain/models/signature_annotation.dart';
import '../../domain/models/stamp_annotation.dart';
import '../../domain/models/highlight_annotation.dart';
import '../../domain/models/shape_annotation.dart';
import '../../domain/models/ink_annotation.dart';

class AnnotationResizeHandles extends StatefulWidget {
  final AnnotationBase? selectedAnnotation;
  final Rect? tempBounds;
  final Function(Rect newBounds) onBoundsUpdate;
  final Function(Rect newBounds) onBoundsCommit;
  final Map<String, dynamic> imageCache;

  const AnnotationResizeHandles({
    super.key,
    required this.selectedAnnotation,
    this.tempBounds,
    required this.onBoundsUpdate,
    required this.onBoundsCommit,
    required this.imageCache,
  });

  @override
  State<AnnotationResizeHandles> createState() => _AnnotationResizeHandlesState();
}

class _AnnotationResizeHandlesState extends State<AnnotationResizeHandles> {
  Rect? _currentBounds;
  ResizeHandle? _activeHandle;
  Offset? _dragStart;
  bool _isDraggingCenter = false;
  Offset? _centerDragStart;
  Rect? _centerDragOriginalBounds;

  @override
  void didUpdateWidget(AnnotationResizeHandles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnnotation?.id != oldWidget.selectedAnnotation?.id) {
      _currentBounds = null;
      _activeHandle = null;
      _dragStart = null;
      _isDraggingCenter = false;
      _centerDragStart = null;
      _centerDragOriginalBounds = null;
    }
  }

  Rect? _getBounds() {
    final annotation = widget.selectedAnnotation;
    if (annotation is StampAnnotation) {
      return annotation.bounds;
    } else if (annotation is SignatureAnnotation) {
      return annotation.bounds;
    } else if (annotation is HighlightAnnotation) {
      return annotation.bounds;
    } else if (annotation is ShapeAnnotation) {
      return annotation.bounds;
    } else if (annotation is InkAnnotation) {
      // Calculate bounds from ink points
      if (annotation.points.isEmpty) return null;
      double minX = annotation.points.first.dx;
      double minY = annotation.points.first.dy;
      double maxX = annotation.points.first.dx;
      double maxY = annotation.points.first.dy;

      for (final point in annotation.points) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }

      // Add padding for thickness
      final padding = annotation.thickness / 2;
      return Rect.fromLTRB(
        minX - padding,
        minY - padding,
        maxX + padding,
        maxY + padding,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedAnnotation == null) {
      return const SizedBox.shrink();
    }

    final bounds = widget.tempBounds ?? _currentBounds ?? _getBounds();
    if (bounds == null) return const SizedBox.shrink();

    return Stack(
      children: [
        ..._buildResizeHandles(bounds),
        _buildCenterDragHandle(bounds),
      ],
    );
  }

  List<Widget> _buildResizeHandles(Rect bounds) {
    const handleSize = 20.0;
    final handles = <Widget>[];

    final positions = {
      ResizeHandle.topLeft: bounds.topLeft,
      ResizeHandle.topRight: bounds.topRight,
      ResizeHandle.bottomLeft: bounds.bottomLeft,
      ResizeHandle.bottomRight: bounds.bottomRight,
      ResizeHandle.centerLeft: bounds.centerLeft,
      ResizeHandle.centerRight: bounds.centerRight,
      ResizeHandle.topCenter: bounds.topCenter,
      ResizeHandle.bottomCenter: bounds.bottomCenter,
    };

    positions.forEach((handle, position) {
      handles.add(
        Positioned(
          left: position.dx - handleSize / 2,
          top: position.dy - handleSize / 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              // Consume tap event to prevent canvas from deselecting
            },
            onTap: () {
              // Consume tap event to prevent canvas from deselecting
            },
            onPanStart: (details) => _onResizeStart(handle, bounds, details),
            onPanUpdate: _onResizeUpdate,
            onPanEnd: _onResizeEnd,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return handles;
  }

  void _onResizeStart(ResizeHandle handle, Rect bounds, DragStartDetails details) {
    setState(() {
      _activeHandle = handle;
      _currentBounds = bounds;
      _dragStart = details.localPosition;
    });
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    if (_activeHandle == null || _currentBounds == null || _dragStart == null) return;

    setState(() {
      final delta = details.localPosition - _dragStart!;
      var newBounds = _currentBounds!;

      switch (_activeHandle!) {
        case ResizeHandle.topLeft:
          newBounds = Rect.fromLTRB(
            newBounds.left + delta.dx,
            newBounds.top + delta.dy,
            newBounds.right,
            newBounds.bottom,
          );
          break;
        case ResizeHandle.topCenter:
          newBounds = Rect.fromLTRB(
            newBounds.left,
            newBounds.top + delta.dy,
            newBounds.right,
            newBounds.bottom,
          );
          break;
        case ResizeHandle.topRight:
          newBounds = Rect.fromLTRB(
            newBounds.left,
            newBounds.top + delta.dy,
            newBounds.right + delta.dx,
            newBounds.bottom,
          );
          break;
        case ResizeHandle.centerLeft:
          newBounds = Rect.fromLTRB(
            newBounds.left + delta.dx,
            newBounds.top,
            newBounds.right,
            newBounds.bottom,
          );
          break;
        case ResizeHandle.centerRight:
          newBounds = Rect.fromLTRB(
            newBounds.left,
            newBounds.top,
            newBounds.right + delta.dx,
            newBounds.bottom,
          );
          break;
        case ResizeHandle.bottomLeft:
          newBounds = Rect.fromLTRB(
            newBounds.left + delta.dx,
            newBounds.top,
            newBounds.right,
            newBounds.bottom + delta.dy,
          );
          break;
        case ResizeHandle.bottomCenter:
          newBounds = Rect.fromLTRB(
            newBounds.left,
            newBounds.top,
            newBounds.right,
            newBounds.bottom + delta.dy,
          );
          break;
        case ResizeHandle.bottomRight:
          newBounds = Rect.fromLTRB(
            newBounds.left,
            newBounds.top,
            newBounds.right + delta.dx,
            newBounds.bottom + delta.dy,
          );
          break;
      }

      if (newBounds.width >= 30 && newBounds.height >= 30) {
        _currentBounds = newBounds;
        _dragStart = details.localPosition;
        widget.onBoundsUpdate(newBounds);
      }
    });
  }

  void _onResizeEnd(DragEndDetails details) {
    if (_currentBounds != null) {
      widget.onBoundsCommit(_currentBounds!);
    }
    setState(() {
      _activeHandle = null;
      _dragStart = null;
      _currentBounds = null;
    });
  }

  Widget _buildCenterDragHandle(Rect bounds) {
    const handleSize = 32.0;
    final center = bounds.center;

    return Positioned(
      left: center.dx - handleSize / 2,
      top: center.dy - handleSize / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          // Consume tap event to prevent canvas from deselecting
        },
        onTap: () {
          // Consume tap event to prevent canvas from deselecting
        },
        onPanStart: (details) => _onCenterDragStart(bounds, details),
        onPanUpdate: _onCenterDragUpdate,
        onPanEnd: _onCenterDragEnd,
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C5CFF),
                Color(0xFF22C55E),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.drag_indicator,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _onCenterDragStart(Rect bounds, DragStartDetails details) {
    setState(() {
      _isDraggingCenter = true;
      _centerDragStart = details.localPosition;
      _centerDragOriginalBounds = bounds;
    });
  }

  void _onCenterDragUpdate(DragUpdateDetails details) {
    if (!_isDraggingCenter || _centerDragStart == null || _centerDragOriginalBounds == null) {
      return;
    }

    setState(() {
      final delta = details.localPosition - _centerDragStart!;
      final newBounds = _centerDragOriginalBounds!.shift(delta);
      _currentBounds = newBounds;
      widget.onBoundsUpdate(newBounds);
    });
  }

  void _onCenterDragEnd(DragEndDetails details) {
    if (_currentBounds != null) {
      widget.onBoundsCommit(_currentBounds!);
    }
    setState(() {
      _isDraggingCenter = false;
      _centerDragStart = null;
      _centerDragOriginalBounds = null;
      _currentBounds = null;
    });
  }
}

enum ResizeHandle {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}
