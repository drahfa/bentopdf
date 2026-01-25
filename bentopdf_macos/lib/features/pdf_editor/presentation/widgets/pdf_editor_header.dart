import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../providers/pdf_editor_provider.dart';

class PdfEditorHeader extends ConsumerWidget {
  final VoidCallback onLoadPdf;

  const PdfEditorHeader({
    super.key,
    required this.onLoadPdf,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Back button
            _buildBackButton(context),
            const SizedBox(width: 10),

            // Brand
            _buildBrand(),
            const Spacer(),

            // Action buttons
            _buildActionButtons(state, notifier, onLoadPdf),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
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
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: PdfEditorTheme.text,
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
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
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xF27C5CFF),
                  Color(0xD922C55E),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: PdfEditorTheme.accent.withOpacity(0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.edit,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Title
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PDF Editor',
                style: TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Annotate & Edit PDFs',
                style: TextStyle(
                  color: PdfEditorTheme.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    PdfEditorState state,
    PdfEditorNotifier notifier,
    VoidCallback onLoadPdf,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Upload/Open button
        _buildActionButton(
          label: 'Open PDF',
          icon: Icons.folder_open,
          onPressed: onLoadPdf,
          isGhost: true,
        ),
        const SizedBox(width: 10),

        // Save/Export button
        if (state.filePath != null)
          _buildActionButton(
            label: 'Export',
            icon: Icons.download,
            onPressed: state.isProcessing ? null : () => notifier.savePdf(),
            isPrimary: true,
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isGood = false,
    bool isGhost = false,
  }) {
    BoxDecoration decoration;
    if (isPrimary) {
      decoration = PdfEditorTheme.buttonDecoration(isPrimary: true);
    } else if (isGood) {
      decoration = PdfEditorTheme.buttonDecoration(isGood: true);
    } else if (isGhost) {
      decoration = BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(999),
      );
    } else {
      decoration = PdfEditorTheme.buttonDecoration();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: PdfEditorTheme.text,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: PdfEditorTheme.buttonStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
