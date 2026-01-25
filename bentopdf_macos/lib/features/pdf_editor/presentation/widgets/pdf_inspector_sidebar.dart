import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../domain/models/annotation_base.dart';
import '../providers/pdf_editor_provider.dart';

class PdfInspectorSidebar extends ConsumerWidget {
  const PdfInspectorSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);

    return GlassPanel(
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inspector',
            style: PdfEditorTheme.headingStyle,
          ),
          Text(
            'Properties',
            style: PdfEditorTheme.mutedStyle,
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
          _buildCard(
            title: 'Annotations',
            subtitle: '${state.currentPageAnnotations.length}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.currentPageAnnotations.map((annotation) {
                final isSelected = annotation.id == state.selectedAnnotationId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
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
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
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
    }
  }
}
