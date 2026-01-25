import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
import 'annotation_resize_handles.dart';

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

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
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

    return ClipRRect(
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
        minScale: 0.5,
        maxScale: 3.0,
        constrained: false,
        onInteractionEnd: (details) {
          // Sync zoom level back to state when user manually zooms
          final scale = _transformationController.value.getMaxScaleOnAxis();
          if ((scale - state.zoomLevel).abs() > 0.01) {
            notifier.changeZoom(scale.clamp(0.5, 3.0));
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
                  behavior: state.selectedTool == AnnotationTool.pan
                      ? HitTestBehavior.deferToChild
                      : HitTestBehavior.translucent,
                  onPanStart: state.selectedTool != AnnotationTool.pan
                      ? (details) =>
                          _onPanStart(details.localPosition, notifier, state)
                      : null,
                  onPanUpdate: state.selectedTool != AnnotationTool.pan
                      ? (details) =>
                          _onPanUpdate(details.localPosition, notifier, state)
                      : null,
                  onPanEnd: state.selectedTool != AnnotationTool.pan
                      ? (details) => _onPanEnd(notifier, state)
                      : null,
                  onTapDown: state.selectedTool != AnnotationTool.pan
                      ? (details) =>
                          _onTapDown(details.localPosition, notifier, state)
                      : null,
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
                          });
                        }
                      },
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
    );
  }

  void _onPanStart(
    Offset position,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    final selectedAnnotation = state.currentPageAnnotations
        .where((a) => a.id == state.selectedAnnotationId)
        .firstOrNull;

    if (selectedAnnotation != null &&
        (selectedAnnotation is StampAnnotation ||
            selectedAnnotation is SignatureAnnotation)) {
      final bounds = _getAnnotationBounds(selectedAnnotation);
      if (bounds != null && bounds.contains(position)) {
        setState(() {
          _isDragging = true;
          _dragStartOffset = position;
          _originalBounds = bounds;
          _tempBounds = bounds;
        });
        return;
      }
    }

    if (state.selectedTool == AnnotationTool.none ||
        state.selectedTool == AnnotationTool.pan) {
      return;
    }

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
    }
    return null;
  }

  void _onPanUpdate(
    Offset position,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    if (_isDragging && _dragStartOffset != null && _originalBounds != null) {
      final delta = position - _dragStartOffset!;
      setState(() {
        _tempBounds = _originalBounds!.shift(delta);
      });
      return;
    }

    if (state.selectedTool == AnnotationTool.none ||
        state.selectedTool == AnnotationTool.pan) {
      return;
    }

    setState(() {
      _currentDrawPoint = position;
      if (state.selectedTool == AnnotationTool.ink) {
        _currentInkPoints.add(position);
      }
    });
  }

  void _onPanEnd(PdfEditorNotifier notifier, PdfEditorState state) {
    if (_isDragging && _tempBounds != null && state.selectedAnnotationId != null) {
      notifier.updateAnnotationBounds(state.selectedAnnotationId!, _tempBounds!);
      setState(() {
        _isDragging = false;
        _dragStartOffset = null;
        _originalBounds = null;
        _tempBounds = null;
      });
      return;
    }

    if (state.selectedTool == AnnotationTool.none ||
        state.selectedTool == AnnotationTool.pan) {
      return;
    }

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
    });
  }

  void _onTapDown(
    Offset position,
    PdfEditorNotifier notifier,
    PdfEditorState state,
  ) {
    for (final annotation in state.currentPageAnnotations.reversed) {
      if (annotation is StampAnnotation || annotation is SignatureAnnotation) {
        final bounds = (annotation is StampAnnotation)
            ? annotation.bounds
            : (annotation as SignatureAnnotation).bounds;

        if (bounds.contains(position)) {
          notifier.selectAnnotation(annotation.id);
          return;
        }
      }
    }

    if (state.selectedTool == AnnotationTool.none) {
      notifier.selectAnnotation(null);
      return;
    }

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

}
