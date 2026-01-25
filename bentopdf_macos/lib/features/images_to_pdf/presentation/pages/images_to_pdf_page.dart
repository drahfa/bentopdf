import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/features/images_to_pdf/presentation/providers/images_to_pdf_provider.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';
import 'package:desktop_drop/desktop_drop.dart';

class ImagesToPdfPage extends ConsumerWidget {
  const ImagesToPdfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imagesToPdfProvider);

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
                _buildHeader(context, state, ref),
                if (state.error != null) _buildErrorBanner(ref, state),
                if (state.successMessage != null) _buildSuccessBanner(ref, state),
                Expanded(
                  child: state.images.isEmpty
                      ? _buildDropZone(context, ref)
                      : _buildImageList(context, ref, state),
                ),
                _buildBottomBar(context, ref, state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ImagesToPdfState state, WidgetRef ref) {
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
                      Icons.photo_library,
                      size: 20,
                      color: PdfEditorTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Images to PDF',
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
            if (state.images.isNotEmpty && !state.isProcessing)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(imagesToPdfProvider.notifier).clearImages(),
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

  Widget _buildErrorBanner(WidgetRef ref, ImagesToPdfState state) {
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
            onPressed: () => ref.read(imagesToPdfProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(WidgetRef ref, ImagesToPdfState state) {
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
            onPressed: () => ref.read(imagesToPdfProvider.notifier).clearSuccess(),
          ),
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
                    Icons.photo_library,
                    size: 64,
                    color: PdfEditorTheme.accent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Drag and drop images here',
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
                    onTap: () => ref.read(imagesToPdfProvider.notifier).addImages(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 20, color: PdfEditorTheme.text),
                          SizedBox(width: 10),
                          Text(
                            'Select Images',
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
                const SizedBox(height: 24),
                Text(
                  'Supported formats: JPG, PNG, GIF, BMP',
                  style: TextStyle(
                    color: PdfEditorTheme.muted,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageList(BuildContext context, WidgetRef ref, ImagesToPdfState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: PdfEditorTheme.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Drag to reorder images • Each image becomes a page',
                  style: TextStyle(
                    color: PdfEditorTheme.muted,
                    fontSize: 12,
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
              ref.read(imagesToPdfProvider.notifier).reorderImages(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final image = state.images[index];
              return Container(
                key: ValueKey(image.path),
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
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drag_handle, color: PdfEditorTheme.muted),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PdfEditorTheme.accent.withOpacity(0.12),
                          border: Border.all(
                            color: PdfEditorTheme.accent.withOpacity(0.25),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.image, color: PdfEditorTheme.accent, size: 24),
                      ),
                    ],
                  ),
                  title: Text(
                    image.name,
                    style: const TextStyle(
                      color: PdfEditorTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Page ${index + 1}',
                    style: const TextStyle(color: PdfEditorTheme.muted, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: PdfEditorTheme.danger,
                    onPressed: () => ref.read(imagesToPdfProvider.notifier).removeImage(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, ImagesToPdfState state) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (state.images.isNotEmpty)
              Text(
                '${state.images.length} image(s) selected',
                style: const TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const Spacer(),
            if (state.images.isNotEmpty && !state.isProcessing)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.read(imagesToPdfProvider.notifier).addImages(),
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
                onTap: state.isProcessing || state.images.isEmpty
                    ? null
                    : () => ref.read(imagesToPdfProvider.notifier).createPdf(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: state.isProcessing || state.images.isEmpty
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
                        const Icon(Icons.picture_as_pdf, size: 18, color: PdfEditorTheme.text),
                      const SizedBox(width: 8),
                      Text(
                        state.isProcessing ? 'Creating...' : 'Create PDF',
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
