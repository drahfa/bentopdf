import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/split_pdf/presentation/providers/split_pdf_provider.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class SplitPdfPage extends ConsumerWidget {
  const SplitPdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(splitPdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
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
                          ref.read(splitPdfProvider.notifier).clearError(),
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
                          ref.read(splitPdfProvider.notifier).clearSuccess(),
                    ),
                  ],
                ),
              ),
            PdfFileSelector(
              selectedFilePath: state.filePath,
              pageCount: state.pageCount,
              onSelectFile: () => ref.read(splitPdfProvider.notifier).selectFile(),
              emptyStateTitle: 'Split your PDF into parts',
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
                        'Page Range',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Start Page',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                text: state.startPage,
                              )..selection = TextSelection.fromPosition(
                                  TextPosition(offset: state.startPage.length),
                                ),
                              onChanged: (value) => ref
                                  .read(splitPdfProvider.notifier)
                                  .setStartPage(value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'End Page',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                text: state.endPage,
                              )..selection = TextSelection.fromPosition(
                                  TextPosition(offset: state.endPage.length),
                                ),
                              onChanged: (value) => ref
                                  .read(splitPdfProvider.notifier)
                                  .setEndPage(value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isProcessing
                              ? null
                              : () =>
                                  ref.read(splitPdfProvider.notifier).splitPdf(),
                          icon: state.isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.call_split),
                          label: Text(state.isProcessing
                              ? 'Splitting...'
                              : 'Split PDF'),
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
