import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:pdfcow/features/extract_pages/presentation/providers/extract_pages_provider.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';

class ExtractPagesPage extends ConsumerWidget {
  const ExtractPagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(extractPagesProvider);

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
                      PdfEditorTheme.accent2.withOpacity(0.08),
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
                if (state.filePath != null && state.pageCount != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select pages to extract',
                      style: const TextStyle(color: PdfEditorTheme.muted, fontSize: 13),
                    ),
                  ),
                  Expanded(child: _buildPageGrid(context, ref, state)),
                ] else
                  Expanded(child: _buildEmptyState(context, ref)),
                if (state.selectedPages.isNotEmpty) _buildBottomBar(context, ref, state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ExtractPagesState state) {
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
                      color: PdfEditorTheme.accent2.withOpacity(0.14),
                      border: Border.all(color: PdfEditorTheme.accent2.withOpacity(0.25), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter, size: 20, color: PdfEditorTheme.accent2),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Extract Pages',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Save Specific Pages',
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
            if (state.filePath != null && state.selectedPages.isNotEmpty)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(extractPagesProvider.notifier).clearSelection(),
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
            if (state.filePath != null) const SizedBox(width: 8),
            if (state.filePath != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(extractPagesProvider.notifier).selectAll(),
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

  Widget _buildErrorBanner(WidgetRef ref, ExtractPagesState state) {
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
            onPressed: () => ref.read(extractPagesProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(WidgetRef ref, ExtractPagesState state) {
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
            onPressed: () => ref.read(extractPagesProvider.notifier).clearSuccess(),
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
                  color: PdfEditorTheme.accent2.withOpacity(0.12),
                  border: Border.all(color: PdfEditorTheme.accent2.withOpacity(0.25), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.upload_file, size: 64, color: PdfEditorTheme.accent2),
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
                  onTap: () => ref.read(extractPagesProvider.notifier).selectFile(),
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

  Widget _buildPageGrid(BuildContext context, WidgetRef ref, ExtractPagesState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: state.pageCount!,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final isSelected = state.selectedPages.contains(pageNumber);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ref.read(extractPagesProvider.notifier).togglePage(pageNumber),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          PdfEditorTheme.accent2.withOpacity(0.20),
                          PdfEditorTheme.accent2.withOpacity(0.12),
                        ],
                      )
                    : PdfEditorTheme.glassGradient,
                border: Border.all(
                  color: isSelected ? PdfEditorTheme.accent2.withOpacity(0.35) : Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Page thumbnail
                    if (state.document != null)
                      FutureBuilder<pdfx.PdfPageImage?>(
                        future: _renderPageThumbnail(state.document!, pageNumber),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Positioned.fill(
                              child: Container(
                                color: Colors.white,
                                child: Image.memory(
                                  snapshot.data!.bytes,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(PdfEditorTheme.muted),
                            ),
                          );
                        },
                      ),
                    // Page number overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Text(
                          'Page $pageNumber',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: PdfEditorTheme.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: PdfEditorTheme.accent2,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PdfEditorTheme.accent2.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
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

  Future<pdfx.PdfPageImage?> _renderPageThumbnail(pdfx.PdfDocument document, int pageNumber) async {
    try {
      final page = await document.getPage(pageNumber);
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

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, ExtractPagesState state) {
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
                onTap: state.isProcessing ? null : () => ref.read(extractPagesProvider.notifier).extractPages(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: state.isProcessing
                      ? BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
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
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(PdfEditorTheme.text)),
                        )
                      else
                        const Icon(Icons.filter, size: 18, color: PdfEditorTheme.text),
                      const SizedBox(width: 8),
                      Text(
                        state.isProcessing ? 'Extracting...' : 'Extract Pages',
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
}
