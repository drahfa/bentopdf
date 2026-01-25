import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PdfFileSelector(
                    selectedFilePath: state.filePath,
                    pageCount: state.pages.length,
                    onSelectFile: () =>
                        ref.read(organizePdfProvider.notifier).selectFile(),
                    emptyStateTitle: 'Reorder and organize pages',
                    emptyStateSubtitle: 'Drop a PDF here or click to browse',
                  ),
                ),
                if (state.filePath != null && state.pages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: PdfEditorTheme.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Drag to reorder • Tap to duplicate or delete',
                            style: TextStyle(
                              color: PdfEditorTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                if (state.filePath != null && state.pages.isNotEmpty)
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.pages.length,
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(organizePdfProvider.notifier)
                            .reorderPages(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final page = state.pages[index];
                        return Container(
                          key: ValueKey(page.id),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: PdfEditorTheme.glassGradient,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.10),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.drag_handle, color: PdfEditorTheme.muted),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: PdfEditorTheme.danger.withOpacity(0.12),
                                    border: Border.all(
                                      color: PdfEditorTheme.danger.withOpacity(0.25),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf, color: PdfEditorTheme.danger, size: 24),
                                ),
                              ],
                            ),
                            title: Text(
                              'Page ${page.originalPageNumber}',
                              style: const TextStyle(
                                color: PdfEditorTheme.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Position: ${index + 1}',
                              style: const TextStyle(color: PdfEditorTheme.muted, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.content_copy, size: 20),
                                  tooltip: 'Duplicate',
                                  color: PdfEditorTheme.accent,
                                  onPressed: () => ref
                                      .read(organizePdfProvider.notifier)
                                      .duplicatePage(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  tooltip: 'Delete',
                                  color: PdfEditorTheme.danger,
                                  onPressed: () => ref
                                      .read(organizePdfProvider.notifier)
                                      .deletePage(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                  const Text(
                    'Organize PDF',
                    style: TextStyle(
                      color: PdfEditorTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
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
