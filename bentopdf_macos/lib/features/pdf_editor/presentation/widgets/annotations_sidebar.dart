import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/annotation_base.dart';
import '../../domain/models/comment_annotation.dart';
import '../providers/pdf_editor_provider.dart';

class AnnotationsSidebar extends ConsumerWidget {
  const AnnotationsSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    if (state.currentPageAnnotations.isEmpty) {
      return Container(
        width: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No annotations on this page',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Annotations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentPageAnnotations.length,
              itemBuilder: (context, index) {
                final annotation = state.currentPageAnnotations[index];
                final isSelected = annotation.id == state.selectedAnnotationId;

                return _buildAnnotationTile(
                  context,
                  annotation,
                  isSelected,
                  () => notifier.selectAnnotation(annotation.id),
                  () => notifier.deleteAnnotation(annotation.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationTile(
    BuildContext context,
    AnnotationBase annotation,
    bool isSelected,
    VoidCallback onTap,
    VoidCallback onDelete,
  ) {
    IconData icon;
    String title;
    String? subtitle;

    switch (annotation.type) {
      case AnnotationType.highlight:
        icon = Icons.highlight;
        title = 'Highlight';
        break;
      case AnnotationType.ink:
        icon = Icons.brush;
        title = 'Drawing';
        break;
      case AnnotationType.signature:
        icon = Icons.edit;
        title = 'Signature';
        break;
      case AnnotationType.stamp:
        icon = Icons.image;
        title = 'Stamp';
        break;
      case AnnotationType.comment:
        icon = Icons.comment;
        title = 'Comment';
        final commentAnnotation = annotation as CommentAnnotation;
        subtitle = commentAnnotation.text.length > 30
            ? '${commentAnnotation.text.substring(0, 30)}...'
            : commentAnnotation.text;
        break;
      case AnnotationType.rectangle:
        icon = Icons.rectangle_outlined;
        title = 'Rectangle';
        break;
      case AnnotationType.circle:
        icon = Icons.circle_outlined;
        title = 'Circle';
        break;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red.shade400,
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
