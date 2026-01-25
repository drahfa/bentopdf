import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/pdf_to_images/presentation/providers/pdf_to_images_provider.dart';
import 'package:pdfcow/shared/services/image_conversion_service.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class PdfToImagesPage extends ConsumerWidget {
  const PdfToImagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfToImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Images'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
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
                          ref.read(pdfToImagesProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
            if (state.successMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
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
                          ref.read(pdfToImagesProvider.notifier).clearSuccess(),
                    ),
                  ],
                ),
              ),
            PdfFileSelector(
              selectedFilePath: state.filePath,
              pageCount: state.pageCount,
              onSelectFile: () =>
                  ref.read(pdfToImagesProvider.notifier).selectFile(),
              emptyStateTitle: 'Export PDF pages as images',
              emptyStateSubtitle: 'Drop a PDF here or click to browse',
            ),
            const SizedBox(height: 16),
            if (state.filePath != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image Format',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('PNG (Lossless)'),
                            selected: state.format == ImageFormat.png,
                            onSelected: (selected) {
                              if (selected) {
                                ref
                                    .read(pdfToImagesProvider.notifier)
                                    .setFormat(ImageFormat.png);
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('JPG (Smaller size)'),
                            selected: state.format == ImageFormat.jpg,
                            onSelected: (selected) {
                              if (selected) {
                                ref
                                    .read(pdfToImagesProvider.notifier)
                                    .setFormat(ImageFormat.jpg);
                              }
                            },
                          ),
                        ],
                      ),
                      if (state.format == ImageFormat.jpg) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Quality: ${state.quality}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: state.quality.toDouble(),
                          min: 50,
                          max: 100,
                          divisions: 10,
                          label: '${state.quality}%',
                          onChanged: (value) {
                            ref
                                .read(pdfToImagesProvider.notifier)
                                .setQuality(value.toInt());
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Each page will be saved as a separate image file. '
                                'Choose a folder to save all images.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.blue,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isProcessing
                              ? null
                              : () => ref
                                  .read(pdfToImagesProvider.notifier)
                                  .convertToImages(),
                          icon: state.isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.image),
                          label: Text(state.isProcessing
                              ? 'Converting...'
                              : 'Convert to Images'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
