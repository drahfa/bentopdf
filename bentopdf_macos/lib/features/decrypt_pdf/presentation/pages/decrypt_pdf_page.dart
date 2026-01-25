import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/decrypt_pdf/presentation/providers/decrypt_pdf_provider.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class DecryptPdfPage extends ConsumerWidget {
  const DecryptPdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(decryptPdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decrypt PDF'),
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
                          ref.read(decryptPdfProvider.notifier).clearError(),
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
                          ref.read(decryptPdfProvider.notifier).clearSuccess(),
                    ),
                  ],
                ),
              ),
            PdfFileSelector(
              selectedFilePath: state.filePath,
              onSelectFile: () =>
                  ref.read(decryptPdfProvider.notifier).selectFile(),
              emptyStateTitle: 'Remove password protection',
              emptyStateSubtitle: 'Drop an encrypted PDF here or click to browse',
            ),
            const SizedBox(height: 16),
            if (state.filePath != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_open, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Enter Password',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter the PDF password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                        ),
                        onChanged: (value) =>
                            ref.read(decryptPdfProvider.notifier).setPassword(value),
                        onSubmitted: (_) {
                          if (!state.isProcessing) {
                            ref.read(decryptPdfProvider.notifier).decryptPdf();
                          }
                        },
                      ),
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
                            const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This will remove password protection and save an unencrypted version of your PDF.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                  .read(decryptPdfProvider.notifier)
                                  .decryptPdf(),
                          icon: state.isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.lock_open),
                          label: Text(
                              state.isProcessing ? 'Decrypting...' : 'Decrypt PDF'),
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
