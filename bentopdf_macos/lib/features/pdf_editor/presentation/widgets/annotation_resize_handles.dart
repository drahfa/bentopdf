import 'package:flutter/material.dart';
import '../../domain/models/annotation_base.dart';
import '../../domain/models/signature_annotation.dart';
import '../../domain/models/stamp_annotation.dart';

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

  @override
  void didUpdateWidget(AnnotationResizeHandles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnnotation?.id != oldWidget.selectedAnnotation?.id) {
      _currentBounds = null;
      _activeHandle = null;
      _dragStart = null;
    }
  }

  Rect? _getBounds() {
    final annotation = widget.selectedAnnotation;
    if (annotation is StampAnnotation) {
      return annotation.bounds;
    } else if (annotation is SignatureAnnotation) {
      return annotation.bounds;
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
      ],
    );
  }

  List<Widget> _buildResizeHandles(Rect bounds) {
    const handleSize = 12.0;
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
            onPanStart: (details) => _onResizeStart(handle, bounds, details),
            onPanUpdate: _onResizeUpdate,
            onPanEnd: _onResizeEnd,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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
