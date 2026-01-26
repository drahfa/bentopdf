import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdfcow/features/organize_pdf/presentation/providers/organize_pdf_provider.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class OrganizePdfPage extends ConsumerWidget {
  const OrganizePdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizePdfProvider);

    return Scaffold(
      body: Container(
        decoration: PdfEditorTheme.backgroundDecoration,
        child: Stack(
          children: [
            Positioned(
              top: -200,
              right: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PdfEditorTheme.accent.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildHeader(context),
                if (state.error != null) _buildErrorBanner(ref, state),
                if (state.successMessage != null) _buildSuccessBanner(ref, state),
                if (state.filePath == null || state.pages.isEmpty)
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: PdfFileSelector(
                            selectedFilePath: state.filePath,
                            pageCount: state.pages.length,
                            onSelectFile: () =>
                                ref.read(organizePdfProvider.notifier).selectFile(),
                            emptyStateTitle: 'Reorder and organize pages',
                            emptyStateSubtitle: 'Drop a PDF here or click to browse',
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: PdfEditorTheme.muted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Drag to reorder • Click duplicate or delete icons',
                                  style: TextStyle(
                                    color: PdfEditorTheme.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildPageGrid(state, ref),
                        ),
                      ],
                    ),
                  ),
                if (state.pages.isNotEmpty)
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${state.pages.length} page(s)',
                            style: const TextStyle(
                              color: PdfEditorTheme.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: state.isProcessing
                                  ? null
                                  : () => ref.read(organizePdfProvider.notifier).savePdf(),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: state.isProcessing
                                    ? BoxDecoration(
                                        color: Colors.black.withOpacity(0.18),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.10),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                      )
                                    : PdfEditorTheme.buttonDecoration(isPrimary: true),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (state.isProcessing)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(PdfEditorTheme.text),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.save, size: 18, color: PdfEditorTheme.text),
                                    const SizedBox(width: 8),
                                    Text(
                                      state.isProcessing ? 'Saving...' : 'Save PDF',
                                      style: const TextStyle(
                                        color: PdfEditorTheme.text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageGrid(OrganizePdfState state, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.pages.length,
      itemBuilder: (context, index) {
        final page = state.pages[index];
        return _DraggablePageCard(
          key: ValueKey(page.id),
          pageNumber: page.originalPageNumber,
          position: index + 1,
          document: state.document,
          index: index,
          onDuplicate: () => ref.read(organizePdfProvider.notifier).duplicatePage(index),
          onDelete: () => ref.read(organizePdfProvider.notifier).deletePage(index),
          canDelete: state.pages.length > 1,
          onReorder: (draggedIndex, targetIndex) {
            ref.read(organizePdfProvider.notifier).reorderPages(draggedIndex, targetIndex);
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: PdfEditorTheme.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PdfEditorTheme.accent.withOpacity(0.14),
                      border: Border.all(
                        color: PdfEditorTheme.accent.withOpacity(0.25),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.reorder,
                      size: 20,
                      color: PdfEditorTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Organize PDF',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Reorder Pages',
                        style: TextStyle(
                          color: PdfEditorTheme.muted,
                          fontSize: 12,
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
    );
  }

  Widget _buildErrorBanner(WidgetRef ref, OrganizePdfState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PdfEditorTheme.danger.withOpacity(0.12),
        border: Border.all(
          color: PdfEditorTheme.danger.withOpacity(0.35),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: PdfEditorTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.error!,
              style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: PdfEditorTheme.muted,
            onPressed: () => ref.read(organizePdfProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(WidgetRef ref, OrganizePdfState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PdfEditorTheme.accent2.withOpacity(0.12),
        border: Border.all(
          color: PdfEditorTheme.accent2.withOpacity(0.35),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: PdfEditorTheme.accent2, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.successMessage!,
              style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: PdfEditorTheme.muted,
            onPressed: () => ref.read(organizePdfProvider.notifier).clearSuccess(),
          ),
        ],
      ),
    );
  }
}

class _DraggablePageCard extends StatefulWidget {
  final int pageNumber;
  final int position;
  final pdfx.PdfDocument? document;
  final int index;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final bool canDelete;
  final Function(int draggedIndex, int targetIndex) onReorder;

  const _DraggablePageCard({
    super.key,
    required this.pageNumber,
    required this.position,
    required this.document,
    required this.index,
    required this.onDuplicate,
    required this.onDelete,
    required this.canDelete,
    required this.onReorder,
  });

  @override
  State<_DraggablePageCard> createState() => _DraggablePageCardState();
}

class _DraggablePageCardState extends State<_DraggablePageCard> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isDragOver = true);
        return details.data != widget.index;
      },
      onLeave: (_) {
        setState(() => _isDragOver = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        widget.onReorder(details.data, widget.index);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            // Show insertion indicator on the left side when dragging over
            if (_isDragOver)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: PdfEditorTheme.accent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: PdfEditorTheme.accent.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: PdfEditorTheme.glassGradient,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
          child: Column(
            children: [
              // Drag handle at top
              Draggable<int>(
                data: widget.index,
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 0.8,
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: PdfEditorTheme.glassGradient,
                        border: Border.all(
                          color: PdfEditorTheme.accent.withOpacity(0.55),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: PdfEditorTheme.accent.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.drag_indicator,
                                size: 20,
                                color: PdfEditorTheme.accent,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Icon(
                                Icons.description_outlined,
                                size: 40,
                                color: PdfEditorTheme.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.drag_indicator,
                      size: 32,
                      color: PdfEditorTheme.muted.withOpacity(0.3),
                    ),
                  ),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: PdfEditorTheme.muted.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Thumbnail
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
                    child: _buildThumbnail(),
                  ),
                ),
              ),

              // Page info and actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Page ${widget.pageNumber}',
                      style: const TextStyle(
                        color: PdfEditorTheme.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            icon: Icon(
                              Icons.content_copy,
                              color: PdfEditorTheme.accent.withOpacity(0.75),
                            ),
                            onPressed: widget.onDuplicate,
                            tooltip: 'Duplicate',
                          ),
                        ),
                        if (widget.canDelete) ...[
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
                              icon: Icon(
                                Icons.delete_outline,
                                color: PdfEditorTheme.danger.withOpacity(0.75),
                              ),
                              onPressed: widget.onDelete,
                              tooltip: 'Delete',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
          ],
        );
      },
    );
  }

  Widget _buildThumbnail() {
    if (widget.document == null) {
      return Container(
        color: Colors.white.withOpacity(0.08),
        child: Center(
          child: Icon(
            Icons.description_outlined,
            size: 32,
            color: PdfEditorTheme.muted.withOpacity(0.5),
          ),
        ),
      );
    }

    return FutureBuilder<pdfx.PdfPageImage?>(
      future: _renderPageThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white.withOpacity(0.08),
            child: Center(
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
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            color: Colors.white.withOpacity(0.08),
            child: Center(
              child: Icon(
                Icons.description_outlined,
                size: 32,
                color: PdfEditorTheme.muted.withOpacity(0.5),
              ),
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Image.memory(
            snapshot.data!.bytes,
            fit: BoxFit.contain,
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
