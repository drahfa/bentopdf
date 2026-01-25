import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/organize_pdf/presentation/providers/organize_pdf_provider.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class OrganizePdfPage extends ConsumerWidget {
  const OrganizePdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizePdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organize PDF'),
      ),
      body: Column(
        children: [
          if (state.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error!)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        ref.read(organizePdfProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
          if (state.successMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.successMessage!)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        ref.read(organizePdfProvider.notifier).clearSuccess(),
                  ),
                ],
              ),
            ),
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
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag to reorder • Tap to duplicate or delete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
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
                  return Card(
                    key: ValueKey(page.id),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_handle),
                          const SizedBox(width: 8),
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                        ],
                      ),
                      title: Text('Page ${page.originalPageNumber}'),
                      subtitle: Text('Position: ${index + 1}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.content_copy),
                            tooltip: 'Duplicate',
                            onPressed: () => ref
                                .read(organizePdfProvider.notifier)
                                .duplicatePage(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '${state.pages.length} page(s)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: state.isProcessing
                        ? null
                        : () =>
                            ref.read(organizePdfProvider.notifier).savePdf(),
                    icon: state.isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(state.isProcessing ? 'Saving...' : 'Save PDF'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
