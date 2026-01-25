import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/merge_pdf/presentation/providers/merge_pdf_provider.dart';
import 'package:desktop_drop/desktop_drop.dart';

class MergePdfPage extends ConsumerWidget {
  const MergePdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mergePdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDF'),
        actions: [
          if (state.files.isNotEmpty && !state.isProcessing)
            TextButton(
              onPressed: () => ref.read(mergePdfProvider.notifier).clearFiles(),
              child: const Text('Clear All'),
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
                    onPressed: () => ref.read(mergePdfProvider.notifier).clearError(),
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
                    onPressed: () => ref.read(mergePdfProvider.notifier).clearSuccess(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.files.isEmpty
                ? _buildDropZone(context, ref)
                : _buildFileList(context, ref, state),
          ),
          _buildBottomBar(context, ref, state),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Drag and drop PDF files here',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'or',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => ref.read(mergePdfProvider.notifier).addFiles(),
              icon: const Icon(Icons.file_open),
              label: const Text('Select Files'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(
      BuildContext context, WidgetRef ref, MergePdfState state) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.files.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(mergePdfProvider.notifier).reorderFiles(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final file = state.files[index];
        return Card(
          key: ValueKey(file.path),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(file.name),
            subtitle: file.pageCount != null
                ? Text('${file.pageCount} pages')
                : const Text('Loading...'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => ref.read(mergePdfProvider.notifier).removeFile(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, MergePdfState state) {
    return Container(
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
          if (state.files.isNotEmpty)
            Text(
              '${state.files.length} file(s) selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const Spacer(),
          if (state.files.isNotEmpty && !state.isProcessing)
            TextButton.icon(
              onPressed: () => ref.read(mergePdfProvider.notifier).addFiles(),
              icon: const Icon(Icons.add),
              label: const Text('Add More'),
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: state.isProcessing || state.files.length < 2
                ? null
                : () => ref.read(mergePdfProvider.notifier).mergePdfs(),
            icon: state.isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.merge),
            label: Text(state.isProcessing ? 'Merging...' : 'Merge PDFs'),
          ),
        ],
      ),
    );
  }
}
