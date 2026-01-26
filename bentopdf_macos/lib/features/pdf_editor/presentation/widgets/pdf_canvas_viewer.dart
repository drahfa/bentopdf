import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/painters/annotation_painter.dart';
import '../providers/pdf_editor_provider.dart';
import '../../../../shared/services/canvas_annotation_service.dart';
import '../../domain/models/annotation_base.dart';
import '../../domain/models/shape_annotation.dart';
import '../../domain/models/highlight_annotation.dart';
import '../../domain/models/ink_annotation.dart';
import '../../domain/models/signature_annotation.dart';
import '../../domain/models/stamp_annotation.dart';
import '../../domain/models/text_annotation.dart';
import 'annotation_resize_handles.dart';
import 'text_dialog.dart';
import 'highlight_dialog.dart';

class PdfCanvasViewer extends ConsumerStatefulWidget {
  const PdfCanvasViewer({super.key});

  @override
  ConsumerState<PdfCanvasViewer> createState() => _PdfCanvasViewerState();
}

class _PdfCanvasViewerState extends ConsumerState<PdfCanvasViewer> {
  Offset? _drawingStartPoint;
  Offset? _currentDrawPoint;
  List<Offset> _currentInkPoints = [];
  Offset? _dragStartOffset;
  Rect? _originalBounds;
  Rect? _tempBounds;
  bool _isDragging = false;
  late TransformationController _transformationController;
  final FocusNode _focusNode = FocusNode();
  DateTime? _lastDragEndTime;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    if (state.currentPageImage == null) {
      return const Center(
        child: Text('No page loaded'),
      );
    }

    final pageImage = state.currentPageImage!;
    final imageSize = Size(
      (pageImage.width ?? 0).toDouble(),
      (pageImage.height ?? 0).toDouble(),
    );

    // Update transformation when zoom changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_transformationController.value.getMaxScaleOnAxis() != state.zoomLevel) {
        _transformationController.value = Matrix4.identity()..scale(state.zoomLevel);
      }
    });

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(event, notifier, state),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.white.withOpacity(0.01),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.4,
        maxScale: 3.0,
        constrained: false,
        onInteractionEnd: (details) {
          // Sync zoom level back to state when user manually zooms
          final scale = _transformationController.value.getMaxScaleOnAxis();
          if ((scale - state.zoomLevel).abs() > 0.01) {
            notifier.changeZoom(scale.clamp(0.4, 3.0));
          }
        },
        child: Center(
          child: Container(
            width: imageSize.width,
            height: imageSize.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: imageSize.width,
                  height: imageSize.height,
                  child: Image.memory(
                    pageImage.bytes,
                    fit: BoxFit.fill,
                    width: imageSize.width,
                    height: imageSize.height,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PDF Page: ${state.currentPageWidth.toInt()}x${state.currentPageHeight.toInt()} pt',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'View (2x): ${imageSize.width.toInt()}x${imageSize.height.toInt()} px',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'Aspect: ${(imageSize.width / imageSize.height).toStringAsFixed(3)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final currentScale = _transformationController.value.getMaxScaleOnAxis();
                    final currentTranslation = _transformationController.value.getTranslation();

                    final newTranslation = Matrix4.identity()
                      ..scale(currentScale)
                      ..translate(
                        currentTranslation.x - event.scrollDelta.dx / currentScale,
                        currentTranslation.y - event.scrollDelta.dy / currentScale,
                      );

                    _transformationController.value = newTranslation;
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: _shouldHandleGestures(state)
                      ? (details) =>
                          _onPanStart(details.localPosition, notifier, state)
                      : null,
                  onPanUpdate: _shouldHandleGestures(state)
                      ? (details) =>
                          _onPanUpdate(details.localPosition, notifier, state)
                      : null,
                  onPanEnd: _shouldHandleGestures(state)
                      ? (details) => _onPanEnd(notifier, state)
                      : null,
                  onTapDown: (details) =>
                      _onTapDown(details.localPosition, notifier, state),
                  child: Stack(
                  children: [
                    CustomPaint(
                      size: imageSize,
                      painter: AnnotationPainter(
                        annotations: _buildAnnotationsWithPreview(state),
                        selectedAnnotationId: state.selectedAnnotationId,
                        imageCache: state.imageCache,
                        tempBoundsOverride: _tempBounds,
                      ),
                    ),
                    AnnotationResizeHandles(
                      selectedAnnotation: state.currentPageAnnotations
                          .where((a) => a.id == state.selectedAnnotationId)
                          .firstOrNull,
                      tempBounds: _tempBounds,
                      onBoundsUpdate: (newBounds) {
                        setState(() {
                          _tempBounds = newBounds;
                        });
                      },
                      onBoundsCommit: (newBounds) {
                        if (state.selectedAnnotationId != null) {
                          notifier.updateAnnotationBounds(
                            state.selectedAnnotationId!,
                            newBounds,
                          );
                          setState(() {
                            _tempBounds = null;
                            _lastDragEndTime = DateTime.now();
                          });
                        }
                      },
                      onCenterDoubleTap: () => _handleCenterDoubleTap(context, notifier, state),
                      imageCache: state.imageCache,
                    ),
                  ],
                ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }

  void _onPanStart(
    Offset position,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    // Check if we're dragging a selected annotation (highest priority)
    final selectedAnnotation = state.currentPageAnnotations
        .where((a) => a.id == state.selectedAnnotationId)
        .firstOrNull;

    if (selectedAnnotation != null) {
      final bounds = _getAnnotationBounds(selectedAnnotation);
      if (bounds != null && bounds.contains(position)) {
        // Allow dragging all annotation types
        setState(() {
          _isDragging = true;
          _dragStartOffset = position;
          _originalBounds = bounds;
          _tempBounds = bounds;
        });
        return;
      }
    }

    // If in Pan mode and not dragging an annotation, let InteractiveViewer handle it
    if (state.selectedTool == AnnotationTool.pan) {
      return;
    }

    // If in Select mode with no annotation selected, do nothing
    if (state.selectedTool == AnnotationTool.none) {
      return;
    }

    // Handle annotation creation (ink, shapes, highlights)
    setState(() {
      if (state.selectedTool == AnnotationTool.ink) {
        _currentInkPoints = [position];
      } else {
        _drawingStartPoint = position;
      }
    });
  }

  Rect? _getAnnotationBounds(AnnotationBase annotation) {
    if (annotation is StampAnnotation) {
      return annotation.bounds;
    } else if (annotation is SignatureAnnotation) {
      return annotation.bounds;
    } else if (annotation is HighlightAnnotation) {
      return annotation.bounds;
    } else if (annotation is ShapeAnnotation) {
      return annotation.bounds;
    } else if (annotation is TextAnnotation) {
      // Calculate bounds from text position and size
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
      return Rect.fromLTWH(
        annotation.position.dx,
        annotation.position.dy,
        textPainter.width,
        textPainter.height,
      );
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

  void _onPanUpdate(
    Offset position,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    // If dragging an annotation, update temp bounds
    if (_isDragging && _dragStartOffset != null && _originalBounds != null) {
      final delta = position - _dragStartOffset!;
      setState(() {
        _tempBounds = _originalBounds!.shift(delta);
      });
      return;
    }

    // If in Pan or Select mode, let InteractiveViewer handle it
    if (state.selectedTool == AnnotationTool.pan ||
        state.selectedTool == AnnotationTool.none) {
      return;
    }

    // Handle annotation drawing (ink, shapes, highlights)
    setState(() {
      _currentDrawPoint = position;
      if (state.selectedTool == AnnotationTool.ink) {
        _currentInkPoints.add(position);
      }
    });
  }

  void _onPanEnd(PdfEditorNotifier notifier, PdfEditorState state) {
    // If we were dragging an annotation, commit the changes
    if (_isDragging && _tempBounds != null && state.selectedAnnotationId != null) {
      notifier.updateAnnotationBounds(state.selectedAnnotationId!, _tempBounds!);
      setState(() {
        _isDragging = false;
        _dragStartOffset = null;
        _originalBounds = null;
        _tempBounds = null;
        _lastDragEndTime = DateTime.now();
      });
      return;
    }

    // If in Pan or Select mode, let InteractiveViewer handle it
    if (state.selectedTool == AnnotationTool.pan ||
        state.selectedTool == AnnotationTool.none) {
      setState(() {
        _lastDragEndTime = DateTime.now();
      });
      return;
    }

    // Complete annotation creation (ink, shapes, highlights)
    if (state.selectedTool == AnnotationTool.ink && _currentInkPoints.isNotEmpty) {
      notifier.addInkAnnotation(_currentInkPoints);
    } else if (_drawingStartPoint != null && _currentDrawPoint != null) {
      final rect = Rect.fromPoints(_drawingStartPoint!, _currentDrawPoint!);

      switch (state.selectedTool) {
        case AnnotationTool.highlight:
          notifier.addHighlightAnnotation(rect);
          break;
        case AnnotationTool.rectangle:
          notifier.addShapeAnnotation(ShapeType.rectangle, rect);
          break;
        case AnnotationTool.circle:
          notifier.addShapeAnnotation(ShapeType.circle, rect);
          break;
        default:
          break;
      }
    }

    setState(() {
      _currentInkPoints = [];
      _drawingStartPoint = null;
      _currentDrawPoint = null;
      _lastDragEndTime = DateTime.now();
    });
  }

  void _onTapDown(
    Offset position,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    // Ignore taps that occur within 200ms of a drag ending (prevents accidental deselection)
    if (_lastDragEndTime != null) {
      final timeSinceDrag = DateTime.now().difference(_lastDragEndTime!);
      if (timeSinceDrag.inMilliseconds < 200) {
        return;
      }
    }

    // Before anything else, check if we're clicking on handles of the selected annotation
    if (state.selectedAnnotationId != null) {
      final selectedAnnotation = state.currentPageAnnotations
          .where((a) => a.id == state.selectedAnnotationId)
          .firstOrNull;
      if (selectedAnnotation != null) {
        final bounds = _getAnnotationBounds(selectedAnnotation);
        if (bounds != null) {
          // Check if clicking on center handle (32px at center with 5px buffer)
          const centerHandleSize = 42.0; // Increased from 32 to give more tolerance
          final center = bounds.center;
          final centerHandleRect = Rect.fromCenter(
            center: center,
            width: centerHandleSize,
            height: centerHandleSize,
          );
          if (centerHandleRect.contains(position)) {
            // Clicked on center handle, don't deselect
            return;
          }

          // Check if clicking on resize handles (20px at corners/edges with buffer)
          const resizeHandleSize = 25.0; // Increased from 20 to give more tolerance
          final handlePositions = [
            bounds.topLeft,
            bounds.topRight,
            bounds.bottomLeft,
            bounds.bottomRight,
            bounds.centerLeft,
            bounds.centerRight,
            bounds.topCenter,
            bounds.bottomCenter,
          ];

          for (final handlePos in handlePositions) {
            final handleRect = Rect.fromCenter(
              center: handlePos,
              width: resizeHandleSize,
              height: resizeHandleSize,
            );
            if (handleRect.contains(position)) {
              // Clicked on resize handle, don't deselect
              return;
            }
          }
        }
      }
    }

    // Check if tapping on any annotation to select it
    for (final annotation in state.currentPageAnnotations.reversed) {
      final bounds = _getAnnotationBounds(annotation);
      if (bounds != null && bounds.contains(position)) {
        notifier.selectAnnotation(annotation.id);
        // Switch to Select mode when annotation is clicked
        notifier.selectTool(AnnotationTool.none);
        return;
      }
    }

    // Tapped on empty space
    if (state.selectedTool == AnnotationTool.none ||
        state.selectedTool == AnnotationTool.pan) {
      notifier.selectAnnotation(null);
      // Switch to Pan mode when document (empty space) is clicked
      notifier.selectTool(AnnotationTool.pan);
      return;
    }

    // Handle comment tool
    if (state.selectedTool == AnnotationTool.comment) {
      _showCommentDialog(context, position, notifier);
    }
  }

  List<AnnotationBase> _buildAnnotationsWithPreview(PdfEditorState state) {
    final annotations = List<AnnotationBase>.from(state.currentPageAnnotations);

    if (state.selectedTool == AnnotationTool.ink && _currentInkPoints.isNotEmpty) {
      annotations.add(
        InkAnnotation(
          id: 'preview',
          pageNumber: state.currentPageNumber,
          createdAt: DateTime.now(),
          points: _currentInkPoints,
          color: state.selectedColor,
          thickness: state.thickness,
          opacity: state.opacity,
        ),
      );
    } else if (_drawingStartPoint != null && _currentDrawPoint != null) {
      final rect = Rect.fromPoints(_drawingStartPoint!, _currentDrawPoint!);

      if (state.selectedTool == AnnotationTool.highlight) {
        annotations.add(
          HighlightAnnotation(
            id: 'preview',
            pageNumber: state.currentPageNumber,
            createdAt: DateTime.now(),
            bounds: rect,
            color: state.selectedColor,
            opacity: state.opacity,
          ),
        );
      } else if (state.selectedTool == AnnotationTool.rectangle) {
        annotations.add(
          ShapeAnnotation(
            id: 'preview',
            pageNumber: state.currentPageNumber,
            createdAt: DateTime.now(),
            shapeType: ShapeType.rectangle,
            bounds: rect,
            color: state.selectedColor,
            opacity: state.opacity,
          ),
        );
      } else if (state.selectedTool == AnnotationTool.circle) {
        annotations.add(
          ShapeAnnotation(
            id: 'preview',
            pageNumber: state.currentPageNumber,
            createdAt: DateTime.now(),
            shapeType: ShapeType.circle,
            bounds: rect,
            color: state.selectedColor,
            opacity: state.opacity,
          ),
        );
      }
    }

    return annotations;
  }

  bool _shouldHandleGestures(PdfEditorState state) {
    // In pan mode, only handle gestures if an annotation is selected or we're actively dragging
    if (state.selectedTool == AnnotationTool.pan) {
      return state.selectedAnnotationId != null || _isDragging;
    }
    // In other modes, always handle gestures
    return true;
  }

  void _showCommentDialog(
    BuildContext context,
    Offset position,
    PdfEditorNotifier notifier,
  ) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter your comment...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                notifier.addCommentAnnotation(
                  textController.text,
                  position,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCenterDoubleTap(
    BuildContext context,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) async {
    final selectedAnnotation = state.currentPageAnnotations
        .where((a) => a.id == state.selectedAnnotationId)
        .firstOrNull;

    if (selectedAnnotation == null) {
      return;
    }

    if (selectedAnnotation is TextAnnotation) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => TextDialog(
          initialText: selectedAnnotation.text,
          initialFontSize: selectedAnnotation.fontSize,
          initialColor: selectedAnnotation.color,
          initialFontWeight: selectedAnnotation.fontWeight,
        ),
      );

      if (result != null) {
        notifier.updateTextAnnotation(
          selectedAnnotation.id,
          result['text'] as String,
          result['fontSize'] as double,
          result['color'] as Color,
          result['fontWeight'] as FontWeight,
        );
      }
    } else if (selectedAnnotation is HighlightAnnotation) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => HighlightDialog(
          initialColor: selectedAnnotation.color,
          initialOpacity: selectedAnnotation.opacity,
        ),
      );

      if (result != null) {
        notifier.updateHighlightAnnotation(
          selectedAnnotation.id,
          result['color'] as Color,
          result['opacity'] as double,
        );
      }
    }
  }

  KeyEventResult _handleKeyEvent(
    KeyEvent event,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    // Only handle key down events
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isMetaPressed = HardwareKeyboard.instance.isMetaPressed; // Cmd on macOS
    final isControlPressed = HardwareKeyboard.instance.isControlPressed; // Ctrl

    // Handle Cmd+C / Ctrl+C (Copy)
    if ((isMetaPressed || isControlPressed) && event.logicalKey == LogicalKeyboardKey.keyC) {
      if (state.selectedAnnotationId != null) {
        notifier.copyAnnotation();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Handle Cmd+V / Ctrl+V (Paste)
    if ((isMetaPressed || isControlPressed) && event.logicalKey == LogicalKeyboardKey.keyV) {
      if (state.copiedAnnotation != null) {
        notifier.pasteAnnotation();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Only handle arrow keys when an annotation is selected
    if (state.selectedAnnotationId == null) {
      return KeyEventResult.ignored;
    }

    final selectedAnnotation = state.currentPageAnnotations
        .where((a) => a.id == state.selectedAnnotationId)
        .firstOrNull;

    if (selectedAnnotation == null) {
      return KeyEventResult.ignored;
    }

    final bounds = _getAnnotationBounds(selectedAnnotation);
    if (bounds == null) {
      return KeyEventResult.ignored;
    }

    // Determine move distance (10px with shift, 1px without)
    final moveDistance = HardwareKeyboard.instance.isShiftPressed ? 10.0 : 1.0;

    Offset delta = Offset.zero;

    // Handle arrow keys
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      delta = Offset(-moveDistance, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      delta = Offset(moveDistance, 0);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      delta = Offset(0, -moveDistance);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      delta = Offset(0, moveDistance);
    } else if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      // Delete selected annotation
      notifier.deleteAnnotation(state.selectedAnnotationId!);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }

    // Apply the movement
    final newBounds = bounds.shift(delta);
    notifier.updateAnnotationBounds(state.selectedAnnotationId!, newBounds);

    return KeyEventResult.handled;
  }

}
