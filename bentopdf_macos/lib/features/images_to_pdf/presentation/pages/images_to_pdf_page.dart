import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/images_to_pdf/presentation/providers/images_to_pdf_provider.dart';
import 'package:desktop_drop/desktop_drop.dart';

class ImagesToPdfPage extends ConsumerWidget {
  const ImagesToPdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imagesToPdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Images to PDF'),
        actions: [
          if (state.images.isNotEmpty && !state.isProcessing)
            TextButton(
              onPressed: () => ref.read(imagesToPdfProvider.notifier).clearImages(),
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
                    onPressed: () =>
                        ref.read(imagesToPdfProvider.notifier).clearError(),
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
                        ref.read(imagesToPdfProvider.notifier).clearSuccess(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.images.isEmpty
                ? _buildDropZone(context, ref)
                : _buildImageList(context, ref, state),
          ),
          _buildBottomBar(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, WidgetRef ref) {
    return DropTarget(
      onDragDone: (details) {
        final imageFiles = details.files
            .where((file) =>
                file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.jpeg') ||
                file.path.toLowerCase().endsWith('.png') ||
                file.path.toLowerCase().endsWith('.gif') ||
                file.path.toLowerCase().endsWith('.bmp'))
            .map((file) => file.path)
            .toList();

        if (imageFiles.isNotEmpty) {
          ref.read(imagesToPdfProvider.notifier).addImages();
        }
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Drag and drop images here',
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
              onPressed: () => ref.read(imagesToPdfProvider.notifier).addImages(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Select Images'),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Supported formats: JPG, PNG, GIF, BMP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList(
      BuildContext context, WidgetRef ref, ImagesToPdfState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Drag to reorder images • Each image becomes a page',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.images.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(imagesToPdfProvider.notifier)
                  .reorderImages(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final image = state.images[index];
              return Card(
                key: ValueKey(image.path),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.drag_handle),
                      const SizedBox(width: 8),
                      const Icon(Icons.image, color: Colors.blue),
                    ],
                  ),
                  title: Text(image.name),
                  subtitle: Text('Page ${index + 1}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        ref.read(imagesToPdfProvider.notifier).removeImage(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, ImagesToPdfState state) {
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
          if (state.images.isNotEmpty)
            Text(
              '${state.images.length} image(s) selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const Spacer(),
          if (state.images.isNotEmpty && !state.isProcessing)
            TextButton.icon(
              onPressed: () => ref.read(imagesToPdfProvider.notifier).addImages(),
              icon: const Icon(Icons.add),
              label: const Text('Add More'),
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: state.isProcessing || state.images.isEmpty
                ? null
                : () => ref.read(imagesToPdfProvider.notifier).createPdf(),
            icon: state.isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(state.isProcessing ? 'Creating...' : 'Create PDF'),
          ),
        ],
      ),
    );
  }
}
