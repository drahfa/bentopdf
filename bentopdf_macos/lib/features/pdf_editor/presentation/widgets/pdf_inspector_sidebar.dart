import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../domain/models/annotation_base.dart';
import '../../domain/models/text_annotation.dart';
import '../../domain/models/highlight_annotation.dart';
import '../providers/pdf_editor_provider.dart';
import 'text_dialog.dart';
import 'highlight_dialog.dart';

class PdfInspectorSidebar extends ConsumerWidget {
  const PdfInspectorSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);

    return GlassPanel(
      child: Column(
        children: [
          // Header
          _buildHeader(ref, state),

          // Content
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, PdfEditorState state) {
    final notifier = ref.read(pdfEditorProvider.notifier);
    final hasCopiedAnnotation = state.copiedAnnotation != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inspector',
            style: PdfEditorTheme.headingStyle,
          ),
          Row(
            children: [
              // Paste button
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: Icon(
                    Icons.paste_outlined,
                    color: hasCopiedAnnotation
                        ? PdfEditorTheme.accent
                        : PdfEditorTheme.muted.withOpacity(0.3),
                  ),
                  onPressed: hasCopiedAnnotation
                      ? () => notifier.pasteAnnotation()
                      : null,
                  tooltip: 'Paste',
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Properties',
                style: PdfEditorTheme.mutedStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PdfEditorState state) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Document info card
        _buildCard(
          title: 'Document',
          subtitle: 'Info',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Pages', '${state.totalPages}'),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Current Page',
                '${state.currentPageNumber}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Zoom',
                '${(state.zoomLevel * 100).toInt()}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Annotations card
        if (state.currentPageAnnotations.isNotEmpty)
          _buildAnnotationsCard(state),
      ],
    );
  }

  Widget _buildAnnotationsCard(PdfEditorState state) {
    return _buildCard(
      title: 'Annotations',
      subtitle: '${state.currentPageAnnotations.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: state.currentPageAnnotations.map((annotation) {
          return _buildAnnotationItem(annotation, state);
        }).toList(),
      ),
    );
  }

  Widget _buildAnnotationItem(AnnotationBase annotation, PdfEditorState state) {
    return Consumer(
      builder: (context, ref, child) {
        final notifier = ref.read(pdfEditorProvider.notifier);
        final isSelected = annotation.id == state.selectedAnnotationId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => notifier.selectAnnotation(annotation.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PdfEditorTheme.accent.withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: isSelected
                        ? PdfEditorTheme.accent.withOpacity(0.35)
                        : Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getAnnotationIcon(annotation.type),
                      size: 14,
                      color: isSelected
                          ? PdfEditorTheme.accent
                          : PdfEditorTheme.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getAnnotationLabel(annotation.type),
                        style: TextStyle(
                          color: isSelected
                              ? PdfEditorTheme.text
                              : PdfEditorTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    // Edit button (for text and highlight annotations)
                    if (annotation is TextAnnotation)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 14,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: PdfEditorTheme.accent.withOpacity(0.75),
                          ),
                          onPressed: () => _showEditTextDialog(context, ref, annotation),
                        ),
                      ),
                    if (annotation is HighlightAnnotation)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 14,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: PdfEditorTheme.accent.withOpacity(0.75),
                          ),
                          onPressed: () => _showEditHighlightDialog(context, ref, annotation),
                        ),
                      ),
                    // Copy button
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 14,
                        icon: Icon(
                          Icons.copy_outlined,
                          color: PdfEditorTheme.accent.withOpacity(0.75),
                        ),
                        onPressed: () {
                          notifier.selectAnnotation(annotation.id);
                          notifier.copyAnnotation();
                        },
                      ),
                    ),
                    // Delete button
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 14,
                        icon: Icon(
                          Icons.delete_outline,
                          color: PdfEditorTheme.danger.withOpacity(0.75),
                        ),
                        onPressed: () {
                          notifier.deleteAnnotation(annotation.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: PdfEditorTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PdfEditorTheme.muted,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: PdfEditorTheme.text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _showEditTextDialog(
    BuildContext context,
    WidgetRef ref,
    TextAnnotation annotation,
  ) async {
    final notifier = ref.read(pdfEditorProvider.notifier);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TextDialog(
        initialText: annotation.text,
        initialFontSize: annotation.fontSize,
        initialColor: annotation.color,
        initialFontWeight: annotation.fontWeight,
      ),
    );

    if (result != null) {
      notifier.updateTextAnnotation(
        annotation.id,
        result['text'] as String,
        result['fontSize'] as double,
        result['color'] as Color,
        result['fontWeight'] as FontWeight,
      );
    }
  }

  Future<void> _showEditHighlightDialog(
    BuildContext context,
    WidgetRef ref,
    HighlightAnnotation annotation,
  ) async {
    final notifier = ref.read(pdfEditorProvider.notifier);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => HighlightDialog(
        initialColor: annotation.color,
        initialOpacity: annotation.opacity,
      ),
    );

    if (result != null) {
      notifier.updateHighlightAnnotation(
        annotation.id,
        result['color'] as Color,
        result['opacity'] as double,
      );
    }
  }

  IconData _getAnnotationIcon(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return Icons.highlight;
      case AnnotationType.ink:
        return Icons.brush;
      case AnnotationType.signature:
        return Icons.edit;
      case AnnotationType.stamp:
        return Icons.image;
      case AnnotationType.comment:
        return Icons.comment;
      case AnnotationType.rectangle:
      case AnnotationType.circle:
        return Icons.rectangle_outlined;
      case AnnotationType.text:
        return Icons.text_fields;
    }
  }

  String _getAnnotationLabel(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return 'Highlight';
      case AnnotationType.ink:
        return 'Drawing';
      case AnnotationType.signature:
        return 'Signature';
      case AnnotationType.stamp:
        return 'Stamp';
      case AnnotationType.comment:
        return 'Comment';
      case AnnotationType.rectangle:
        return 'Rectangle';
      case AnnotationType.circle:
        return 'Circle';
      case AnnotationType.text:
        return 'Text';
    }
  }
}
