import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/features/pdf_to_images/presentation/providers/pdf_to_images_provider.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';
import 'package:pdfcow/shared/services/image_conversion_service.dart';
import 'package:pdfcow/shared/widgets/pdf_file_selector.dart';

class PdfToImagesPage extends ConsumerWidget {
  const PdfToImagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfToImagesProvider);

    return Scaffold(
      body: Container(
        decoration: PdfEditorTheme.backgroundDecoration,
        child: Stack(
          children: [
            Positioned(
              bottom: -200,
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
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            PdfFileSelector(
                              selectedFilePath: state.filePath,
                              pageCount: state.pageCount,
                              onSelectFile: () =>
                                  ref.read(pdfToImagesProvider.notifier).selectFile(),
                              emptyStateTitle: 'Export PDF pages as images',
                              emptyStateSubtitle: 'Drop a PDF here or click to browse',
                            ),
                            const SizedBox(height: 16),
                            if (state.filePath != null) _buildOptionsCard(context, ref, state),
                          ],
                        ),
                      ),
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
                      Icons.image,
                      size: 20,
                      color: PdfEditorTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PDF to Images',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Convert to PNG/JPEG',
                        style: TextStyle(
                          color: PdfEditorTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(WidgetRef ref, PdfToImagesState state) {
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
            onPressed: () => ref.read(pdfToImagesProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(WidgetRef ref, PdfToImagesState state) {
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
            onPressed: () => ref.read(pdfToImagesProvider.notifier).clearSuccess(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context, WidgetRef ref, PdfToImagesState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: PdfEditorTheme.glassGradient,
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image Format',
            style: TextStyle(
              color: PdfEditorTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
                    ref.read(pdfToImagesProvider.notifier).setFormat(ImageFormat.png);
                  }
                },
              ),
              ChoiceChip(
                label: const Text('JPG (Smaller size)'),
                selected: state.format == ImageFormat.jpg,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(pdfToImagesProvider.notifier).setFormat(ImageFormat.jpg);
                  }
                },
              ),
            ],
          ),
          if (state.format == ImageFormat.jpg) ...[
            const SizedBox(height: 24),
            Text(
              'Quality: ${state.quality}%',
              style: const TextStyle(
                color: PdfEditorTheme.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: state.quality.toDouble(),
              min: 50,
              max: 100,
              divisions: 10,
              label: '${state.quality}%',
              onChanged: (value) {
                ref.read(pdfToImagesProvider.notifier).setQuality(value.toInt());
              },
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PdfEditorTheme.accent.withOpacity(0.10),
              border: Border.all(
                color: PdfEditorTheme.accent.withOpacity(0.25),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: PdfEditorTheme.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Each page will be saved as a separate image file. Choose a folder to save all images.',
                    style: TextStyle(
                      color: PdfEditorTheme.text.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: state.isProcessing
                  ? null
                  : () => ref.read(pdfToImagesProvider.notifier).convertToImages(),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      const Icon(Icons.image, size: 18, color: PdfEditorTheme.text),
                    const SizedBox(width: 10),
                    Text(
                      state.isProcessing ? 'Converting...' : 'Convert to Images',
                      style: const TextStyle(
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
    );
  }
}
