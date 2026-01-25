import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/rotate_pdf/presentation/providers/rotate_pdf_provider.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class RotatePdfPage extends ConsumerWidget {
  const RotatePdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rotatePdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotate PDF'),
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
                          ref.read(rotatePdfProvider.notifier).clearError(),
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
                          ref.read(rotatePdfProvider.notifier).clearSuccess(),
                    ),
                  ],
                ),
              ),
            PdfFileSelector(
              selectedFilePath: state.filePath,
              pageCount: state.pageCount,
              onSelectFile: () => ref.read(rotatePdfProvider.notifier).selectFile(),
              emptyStateTitle: 'Rotate your PDF pages',
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
                        'Rotation Angle',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final degrees in [90, 180, 270])
                            ChoiceChip(
                              label: Text('$degrees°'),
                              selected: state.rotationDegrees == degrees,
                              onSelected: (selected) {
                                if (selected) {
                                  ref
                                      .read(rotatePdfProvider.notifier)
                                      .setRotation(degrees);
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isProcessing
                              ? null
                              : () => ref
                                  .read(rotatePdfProvider.notifier)
                                  .rotatePdf(),
                          icon: state.isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.rotate_90_degrees_cw),
                          label: Text(state.isProcessing
                              ? 'Rotating...'
                              : 'Rotate PDF'),
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
