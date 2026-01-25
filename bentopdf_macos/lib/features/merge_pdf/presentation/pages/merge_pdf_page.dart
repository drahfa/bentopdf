import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/features/merge_pdf/presentation/providers/merge_pdf_provider.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';
import 'package:desktop_drop/desktop_drop.dart';

class MergePdfPage extends ConsumerWidget {
  const MergePdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mergePdfProvider);

    return Scaffold(
      body: Container(
        decoration: PdfEditorTheme.backgroundDecoration,
        child: Stack(
          children: [
            Positioned(
              top: -200,
              left: -100,
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
                _buildHeader(context, ref, state),
                if (state.error != null) _buildErrorBanner(ref, state),
                if (state.successMessage != null) _buildSuccessBanner(ref, state),
                Expanded(
                  child: state.files.isEmpty
                      ? _buildDropZone(context, ref)
                      : _buildFileList(context, ref, state),
                ),
                if (state.files.isNotEmpty) _buildBottomBar(context, ref, state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, MergePdfState state) {
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
                      Icons.merge,
                      size: 20,
                      color: PdfEditorTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Merge PDF',
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
            const Spacer(),
            if (state.files.isNotEmpty && !state.isProcessing)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(mergePdfProvider.notifier).clearFiles(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_all, size: 18, color: PdfEditorTheme.text),
                        SizedBox(width: 8),
                        Text('Clear All', style: TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildErrorBanner(WidgetRef ref, MergePdfState state) {
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
            onPressed: () => ref.read(mergePdfProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(WidgetRef ref, MergePdfState state) {
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
            onPressed: () => ref.read(mergePdfProvider.notifier).clearSuccess(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, WidgetRef ref) {
    return DropTarget(
      onDragDone: (details) {
        final pdfFiles = details.files
            .where((file) => file.path.toLowerCase().endsWith('.pdf'))
            .map((file) => file.path)
            .toList();

        if (pdfFiles.isNotEmpty) {
          ref.read(mergePdfProvider.notifier).addFiles();
        }
      },
      child: Center(
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
                    color: PdfEditorTheme.accent.withOpacity(0.12),
                    border: Border.all(
                      color: PdfEditorTheme.accent.withOpacity(0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.upload_file,
                    size: 64,
                    color: PdfEditorTheme.accent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Drag and drop PDF files here',
                  style: TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
                    onTap: () => ref.read(mergePdfProvider.notifier).addFiles(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_open, size: 20, color: PdfEditorTheme.text),
                          SizedBox(width: 10),
                          Text(
                            'Select Files',
                            style: TextStyle(
                              color: PdfEditorTheme.text,
                              fontSize: 14,
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
      ),
    );
  }

  Widget _buildFileList(BuildContext context, WidgetRef ref, MergePdfState state) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.files.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(mergePdfProvider.notifier).reorderFiles(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final file = state.files[index];
        return Container(
          key: ValueKey(file.path),
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
            leading: Container(
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
            title: Text(
              file.name,
              style: const TextStyle(
                color: PdfEditorTheme.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: file.pageCount != null
                ? Text(
                    '${file.pageCount} pages',
                    style: const TextStyle(color: PdfEditorTheme.muted, fontSize: 12),
                  )
                : const Text(
                    'Loading...',
                    style: TextStyle(color: PdfEditorTheme.muted, fontSize: 12),
                  ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: PdfEditorTheme.danger,
              onPressed: () => ref.read(mergePdfProvider.notifier).removeFile(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, MergePdfState state) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '${state.files.length} file(s) selected',
              style: const TextStyle(
                color: PdfEditorTheme.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (!state.isProcessing)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(mergePdfProvider.notifier).addFiles(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: PdfEditorTheme.text),
                        SizedBox(width: 8),
                        Text('Add More', style: TextStyle(color: PdfEditorTheme.text, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: state.isProcessing || state.files.length < 2
                    ? null
                    : () => ref.read(mergePdfProvider.notifier).mergePdfs(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: state.isProcessing || state.files.length < 2
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
                        const Icon(Icons.merge, size: 18, color: PdfEditorTheme.text),
                      const SizedBox(width: 8),
                      Text(
                        state.isProcessing ? 'Merging...' : 'Merge PDFs',
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
    );
  }
}
