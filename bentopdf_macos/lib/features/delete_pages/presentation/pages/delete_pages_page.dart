import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/delete_pages/presentation/providers/delete_pages_provider.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class DeletePagesPage extends ConsumerWidget {
  const DeletePagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deletePagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Pages'),
        actions: [
          if (state.filePath != null && state.selectedPages.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(deletePagesProvider.notifier).clearSelection(),
              child: const Text('Clear'),
            ),
          if (state.filePath != null)
            TextButton(
              onPressed: () =>
                  ref.read(deletePagesProvider.notifier).selectAll(),
              child: const Text('Select All'),
            ),
        ],
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
                        ref.read(deletePagesProvider.notifier).clearError(),
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
                        ref.read(deletePagesProvider.notifier).clearSuccess(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PdfFileSelector(
              selectedFilePath: state.filePath,
              pageCount: state.pageCount,
              onSelectFile: () =>
                  ref.read(deletePagesProvider.notifier).selectFile(),
              emptyStateTitle: 'Remove unwanted pages',
              emptyStateSubtitle: 'Drop a PDF here or click to browse',
            ),
          ),
          if (state.filePath != null && state.pageCount != null)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: state.pageCount!,
                itemBuilder: (context, index) {
                  final pageNumber = index + 1;
                  final isSelected = state.selectedPages.contains(pageNumber);
                  return InkWell(
                    onTap: () => ref
                        .read(deletePagesProvider.notifier)
                        .togglePage(pageNumber),
                    child: Card(
                      color: isSelected
                          ? Colors.red.withValues(alpha: 0.2)
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 48,
                            color: isSelected ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Page $pageNumber',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.red,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (state.selectedPages.isNotEmpty)
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
                    '${state.selectedPages.length} page(s) selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: state.isProcessing
                        ? null
                        : () => ref
                            .read(deletePagesProvider.notifier)
                            .deletePages(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: state.isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete),
                    label: Text(
                        state.isProcessing ? 'Deleting...' : 'Delete Pages'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
