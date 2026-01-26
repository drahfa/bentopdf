import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../providers/pdf_editor_provider.dart';
import '../../data/painters/annotation_painter.dart';
import '../../domain/models/annotation_base.dart';

class PdfPagesSidebar extends ConsumerWidget {
  const PdfPagesSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    return GlassPanel(
      child: Column(
        children: [
          // Header
          _buildHeader(state),

          // Page thumbnails
          Expanded(
            child: _buildPageThumbnails(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PdfEditorState state) {
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
            'Pages',
            style: PdfEditorTheme.headingStyle,
          ),
          Text(
            '${state.totalPages} pages',
            style: PdfEditorTheme.mutedStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildPageThumbnails(
    PdfEditorState state,
    PdfEditorNotifier notifier,
  ) {
    if (state.totalPages == 0) {
      return const Center(
        child: Text(
          'No pages',
          style: PdfEditorTheme.mutedStyle,
        ),
      );
    }

    // Watch for annotation changes by referencing state
    final _ = state.currentPageAnnotations;

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(12),
      buildDefaultDragHandles: false,
      itemCount: state.totalPages,
      onReorder: (oldIndex, newIndex) {
        // Create new order list
        final newOrder = List<int>.generate(state.totalPages, (i) => i + 1);
        final item = newOrder.removeAt(oldIndex);

        // Adjust newIndex if moving down
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        newOrder.insert(newIndex, item);
        notifier.reorderPages(newOrder);
      },
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final isActive = pageNumber == state.currentPageNumber;

        return Container(
          key: ValueKey('thumbnail_$pageNumber'),
          height: 200,
          margin: const EdgeInsets.only(bottom: 12),
          child: PageThumbnailWidget(
            pageNumber: pageNumber,
            isActive: isActive,
            document: state.document,
            imageCache: state.imageCache,
            totalPages: state.totalPages,
            index: index,
            onTap: () => notifier.goToPage(pageNumber),
            onDelete: () => notifier.deletePage(pageNumber),
            onDuplicate: () => notifier.duplicatePage(pageNumber),
            onRotate: () => notifier.rotatePage(pageNumber, 90),
          ),
        );
      },
    );
  }

}

class PageThumbnailWidget extends ConsumerStatefulWidget {
  final int pageNumber;
  final bool isActive;
  final pdfx.PdfDocument? document;
  final Map<String, ui.Image> imageCache;
  final int totalPages;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onRotate;

  const PageThumbnailWidget({
    super.key,
    required this.pageNumber,
    required this.isActive,
    required this.document,
    required this.imageCache,
    required this.totalPages,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onRotate,
  });

  @override
  ConsumerState<PageThumbnailWidget> createState() => _PageThumbnailWidgetState();
}

class _PageThumbnailWidgetState extends ConsumerState<PageThumbnailWidget> {
  @override
  Widget build(BuildContext context) {
    // Get annotations for this page from the notifier
    final pageAnnotations = ref.read(pdfEditorProvider.notifier).getAnnotationsForPage(widget.pageNumber);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isActive
                ? PdfEditorTheme.accent.withOpacity(0.12)
                : Colors.black.withOpacity(0.18),
            border: Border.all(
              color: widget.isActive
                  ? PdfEditorTheme.accent.withOpacity(0.55)
                  : Colors.white.withOpacity(0.10),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: PdfEditorTheme.accent.withOpacity(0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Thumbnail preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildPagePreview(pageAnnotations),
                  ),
                ),
              ),

              // Page label and actions
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: widget.index,
                          child: Icon(
                            Icons.drag_indicator,
                            size: 16,
                            color: PdfEditorTheme.muted.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Page ${widget.pageNumber}',
                          style: TextStyle(
                            color: widget.isActive
                                ? PdfEditorTheme.text
                                : PdfEditorTheme.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Duplicate button
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 12,
                            icon: Icon(
                              Icons.copy_outlined,
                              color: PdfEditorTheme.accent.withOpacity(0.75),
                            ),
                            onPressed: widget.onDuplicate,
                            tooltip: 'Duplicate',
                          ),
                        ),
                        const SizedBox(width: 1),
                        // Rotate button
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 12,
                            icon: Icon(
                              Icons.rotate_right,
                              color: PdfEditorTheme.accent.withOpacity(0.75),
                            ),
                            onPressed: widget.onRotate,
                            tooltip: 'Rotate 90°',
                          ),
                        ),
                        const SizedBox(width: 1),
                        // Delete button
                        if (widget.totalPages > 1)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              icon: Icon(
                                Icons.delete_outline,
                                color: PdfEditorTheme.danger.withOpacity(0.75),
                              ),
                              onPressed: () => _showDeleteConfirmation(context),
                              tooltip: 'Delete',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagePreview(List<AnnotationBase> pageAnnotations) {
    if (widget.document == null) {
      return Center(
        child: Icon(
          Icons.description_outlined,
          size: 32,
          color: PdfEditorTheme.muted.withOpacity(0.5),
        ),
      );
    }

    return FutureBuilder<pdfx.PdfPageImage?>(
      future: _renderPageThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  PdfEditorTheme.muted.withOpacity(0.5),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Icon(
              Icons.description_outlined,
              size: 32,
              color: PdfEditorTheme.muted.withOpacity(0.5),
            ),
          );
        }

        final pageImage = snapshot.data!;

        return Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                pageImage.bytes,
                fit: BoxFit.contain,
              ),
              if (pageAnnotations.isNotEmpty)
                CustomPaint(
                  painter: AnnotationPainter(
                    annotations: pageAnnotations,
                    selectedAnnotationId: null,
                    imageCache: widget.imageCache,
                    tempBoundsOverride: null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<pdfx.PdfPageImage?> _renderPageThumbnail() async {
    if (widget.document == null) return null;

    try {
      final page = await widget.document!.getPage(widget.pageNumber);
      final pageImage = await page.render(
        width: page.width * 0.5,
        height: page.height * 0.5,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();
      return pageImage;
    } catch (e) {
      return null;
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Page?',
          style: TextStyle(color: PdfEditorTheme.text),
        ),
        content: Text(
          'Are you sure you want to delete page ${widget.pageNumber}? This action cannot be undone.',
          style: const TextStyle(color: PdfEditorTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: PdfEditorTheme.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: PdfEditorTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      widget.onDelete();
    }
  }
}
