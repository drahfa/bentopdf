import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdfcow/features/delete_pages/presentation/providers/delete_pages_provider.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';

class DeletePagesPage extends ConsumerWidget {
  const DeletePagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deletePagesProvider);

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
                      PdfEditorTheme.danger.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildHeader(context, ref, state),
                if (state.error != null) _buildErrorBanner(ref, state),
                if (state.successMessage != null) _buildSuccessBanner(ref, state),
                if (state.filePath != null && state.pageCount != null)
                  Expanded(child: _buildPageGrid(context, ref, state))
                else
                  Expanded(child: _buildEmptyState(context, ref)),
                if (state.selectedPages.isNotEmpty || state.previewMode) _buildBottomBar(context, ref, state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DeletePagesState state) {
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
                    border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: PdfEditorTheme.text),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PdfEditorTheme.danger.withOpacity(0.14),
                      border: Border.all(color: PdfEditorTheme.danger.withOpacity(0.25), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, size: 20, color: PdfEditorTheme.danger),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Delete Pages',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Remove Unwanted Pages',
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
            const Spacer(),
            if (state.filePath != null && state.selectedPages.isNotEmpty && !state.previewMode)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(deletePagesProvider.notifier).clearSelection(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Clear', style: TextStyle(color: PdfEditorTheme.text, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            if (state.filePath != null && !state.previewMode) const SizedBox(width: 8),
            if (state.filePath != null && !state.previewMode)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(deletePagesProvider.notifier).selectAll(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Select All', style: TextStyle(color: PdfEditorTheme.text, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(WidgetRef ref, DeletePagesState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PdfEditorTheme.danger.withOpacity(0.12),
        border: Border.all(color: PdfEditorTheme.danger.withOpacity(0.35), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: PdfEditorTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(state.error!, style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13))),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: PdfEditorTheme.muted,
            onPressed: () => ref.read(deletePagesProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(WidgetRef ref, DeletePagesState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PdfEditorTheme.accent2.withOpacity(0.12),
        border: Border.all(color: PdfEditorTheme.accent2.withOpacity(0.35), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: PdfEditorTheme.accent2, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(state.successMessage!, style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13))),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: PdfEditorTheme.muted,
            onPressed: () => ref.read(deletePagesProvider.notifier).clearSuccess(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: GlassPanel(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PdfEditorTheme.danger.withOpacity(0.12),
                  border: Border.all(color: PdfEditorTheme.danger.withOpacity(0.25), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.upload_file, size: 64, color: PdfEditorTheme.danger),
              ),
              const SizedBox(height: 24),
              const Text(
                'Drag and drop a PDF file here',
                style: TextStyle(color: PdfEditorTheme.text, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'or',
                style: TextStyle(
                  color: PdfEditorTheme.muted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(deletePagesProvider.notifier).selectFile(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_open, size: 20, color: PdfEditorTheme.text),
                        SizedBox(width: 10),
                        Text('Select Files', style: TextStyle(color: PdfEditorTheme.text, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageGrid(BuildContext context, WidgetRef ref, DeletePagesState state) {
    // In preview mode, show only remaining pages
    final pages = state.previewMode && state.remainingPages != null
        ? state.remainingPages!
        : List.generate(state.pageCount!, (i) => i + 1);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final pageNumber = pages[index];
        final isSelected = !state.previewMode && state.selectedPages.contains(pageNumber);
        return _PageCard(
          pageNumber: pageNumber,
          isSelected: isSelected,
          document: state.document,
          onTap: state.previewMode ? () {} : () => ref.read(deletePagesProvider.notifier).togglePage(pageNumber),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, DeletePagesState state) {
    if (state.previewMode) {
      // Preview mode: show remaining pages info and Save/Cancel buttons
      return GlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${state.remainingPages?.length ?? 0} page(s) remaining',
                style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              // Cancel button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: state.isProcessing ? null : () => ref.read(deletePagesProvider.notifier).cancelPreview(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Save PDF button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: state.isProcessing ? null : () => ref.read(deletePagesProvider.notifier).savePdf(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: state.isProcessing
                        ? BoxDecoration(
                            color: Colors.black.withOpacity(0.18),
                            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
                            borderRadius: BorderRadius.circular(999),
                          )
                        : BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PdfEditorTheme.accent2.withOpacity(0.40),
                                PdfEditorTheme.accent2.withOpacity(0.30),
                              ],
                            ),
                            border: Border.all(color: PdfEditorTheme.accent2.withOpacity(0.35), width: 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.isProcessing)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(PdfEditorTheme.text)),
                          )
                        else
                          const Icon(Icons.save, size: 18, color: PdfEditorTheme.text),
                        const SizedBox(width: 8),
                        Text(
                          state.isProcessing ? 'Saving...' : 'Save PDF',
                          style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Normal mode: show selected pages and Delete Pages button
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '${state.selectedPages.length} page(s) selected',
              style: const TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(deletePagesProvider.notifier).deletePages(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PdfEditorTheme.danger.withOpacity(0.40),
                        PdfEditorTheme.danger.withOpacity(0.30),
                      ],
                    ),
                    border: Border.all(color: PdfEditorTheme.danger.withOpacity(0.35), width: 1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, size: 18, color: PdfEditorTheme.text),
                      SizedBox(width: 8),
                      Text(
                        'Delete Pages',
                        style: TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCard extends StatefulWidget {
  final int pageNumber;
  final bool isSelected;
  final pdfx.PdfDocument? document;
  final VoidCallback onTap;

  const _PageCard({
    required this.pageNumber,
    required this.isSelected,
    required this.document,
    required this.onTap,
  });

  @override
  State<_PageCard> createState() => _PageCardState();
}

class _PageCardState extends State<_PageCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PdfEditorTheme.danger.withOpacity(0.20),
                      PdfEditorTheme.danger.withOpacity(0.12),
                    ],
                  )
                : PdfEditorTheme.glassGradient,
            border: Border.all(
              color: widget.isSelected ? PdfEditorTheme.danger.withOpacity(0.35) : Colors.white.withOpacity(0.10),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _buildThumbnail(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Page ${widget.pageNumber}',
                      style: TextStyle(
                        color: widget.isSelected ? PdfEditorTheme.text : PdfEditorTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle, color: PdfEditorTheme.danger, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        width: page.width * 0.4,
        height: page.height * 0.4,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();
      return pageImage;
    } catch (e) {
      return null;
    }
  }
}
