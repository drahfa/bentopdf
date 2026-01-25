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

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: state.totalPages,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final isActive = pageNumber == state.currentPageNumber;

        // Watch for annotation changes by referencing state
        // This ensures thumbnails rebuild when annotations change
        final _ = state.currentPageAnnotations;

        return PageThumbnailWidget(
          key: ValueKey('thumbnail_$pageNumber\_${state.currentPageAnnotations.length}'),
          pageNumber: pageNumber,
          isActive: isActive,
          document: state.document,
          imageCache: state.imageCache,
          onTap: () => notifier.goToPage(pageNumber),
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
  final VoidCallback onTap;

  const PageThumbnailWidget({
    super.key,
    required this.pageNumber,
    required this.isActive,
    required this.document,
    required this.imageCache,
    required this.onTap,
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

              // Page label
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
}
