import 'dart:typed_data';
import 'package:flutter/material.dart';

class AnnotationPlacementOverlay extends StatefulWidget {
  final Size canvasSize;
  final Uint8List imageData;
  final Function(Rect bounds) onPlaced;
  final VoidCallback onCancelled;

  const AnnotationPlacementOverlay({
    super.key,
    required this.canvasSize,
    required this.imageData,
    required this.onPlaced,
    required this.onCancelled,
  });

  @override
  State<AnnotationPlacementOverlay> createState() =>
      _AnnotationPlacementOverlayState();
}

class _AnnotationPlacementOverlayState
    extends State<AnnotationPlacementOverlay> {
  late Rect _bounds;
  Offset? _dragStart;
  Rect? _resizeBounds;
  ResizeHandle? _activeHandle;

  @override
  void initState() {
    super.initState();
    final initialWidth = widget.canvasSize.width * 0.3;
    final initialHeight = initialWidth * 0.5;
    final centerX = (widget.canvasSize.width - initialWidth) / 2;
    final centerY = (widget.canvasSize.height - initialHeight) / 2;

    _bounds = Rect.fromLTWH(centerX, centerY, initialWidth, initialHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        Positioned(
          left: _bounds.left,
          top: _bounds.top,
          width: _bounds.width,
          height: _bounds.height,
          child: GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Image.memory(
                widget.imageData,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        ..._buildResizeHandles(),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                onPressed: widget.onCancelled,
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Place Here'),
                onPressed: () => widget.onPlaced(_bounds),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildResizeHandles() {
    const handleSize = 16.0;
    final handles = <Widget>[];

    final positions = {
      ResizeHandle.topLeft: _bounds.topLeft,
      ResizeHandle.topCenter: _bounds.topCenter,
      ResizeHandle.topRight: _bounds.topRight,
      ResizeHandle.centerLeft: _bounds.centerLeft,
      ResizeHandle.centerRight: _bounds.centerRight,
      ResizeHandle.bottomLeft: _bounds.bottomLeft,
      ResizeHandle.bottomCenter: _bounds.bottomCenter,
      ResizeHandle.bottomRight: _bounds.bottomRight,
    };

    positions.forEach((handle, position) {
      handles.add(
        Positioned(
          left: position.dx - handleSize / 2,
          top: position.dy - handleSize / 2,
          child: GestureDetector(
            onPanStart: (details) => _onResizeStart(handle, details),
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

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _dragStart = details.localPosition;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;

    setState(() {
      final delta = details.localPosition - _dragStart!;
      _bounds = _bounds.shift(delta);
      _dragStart = details.localPosition;

      _bounds = _constrainBounds(_bounds);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _dragStart = null;
  }

  void _onResizeStart(ResizeHandle handle, DragStartDetails details) {
    setState(() {
      _activeHandle = handle;
      _resizeBounds = _bounds;
    });
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    if (_activeHandle == null || _resizeBounds == null) return;

    setState(() {
      final delta = details.delta;
      var newBounds = _resizeBounds!;

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

      if (newBounds.width >= 50 && newBounds.height >= 25) {
        _bounds = _constrainBounds(newBounds);
        _resizeBounds = _bounds;
      }
    });
  }

  void _onResizeEnd(DragEndDetails details) {
    _activeHandle = null;
    _resizeBounds = null;
  }

  Rect _constrainBounds(Rect bounds) {
    var left = bounds.left.clamp(0.0, widget.canvasSize.width - 50);
    var top = bounds.top.clamp(0.0, widget.canvasSize.height - 25);
    var right = bounds.right.clamp(50.0, widget.canvasSize.width);
    var bottom = bounds.bottom.clamp(25.0, widget.canvasSize.height);

    if (right <= left) right = left + 50;
    if (bottom <= top) bottom = top + 25;

    return Rect.fromLTRB(left, top, right, bottom);
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
