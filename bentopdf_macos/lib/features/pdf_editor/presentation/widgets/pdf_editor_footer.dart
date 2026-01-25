import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../providers/pdf_editor_provider.dart';

class PdfEditorFooter extends ConsumerWidget {
  const PdfEditorFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);

    return GlassPanel(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Status indicator
            _buildStatus(state),

            const Spacer(),

            // File path or message
            if (state.filePath != null)
              Expanded(
                child: Text(
                  _getFileName(state.filePath!),
                  style: const TextStyle(
                    color: PdfEditorTheme.muted,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(PdfEditorState state) {
    Color statusColor;
    String statusText;

    if (state.isProcessing) {
      statusColor = PdfEditorTheme.warn;
      statusText = 'Processing...';
    } else if (state.error != null) {
      statusColor = PdfEditorTheme.danger;
      statusText = 'Error';
    } else if (state.successMessage != null) {
      statusColor = PdfEditorTheme.accent2;
      statusText = 'Success';
    } else {
      statusColor = PdfEditorTheme.accent2;
      statusText = 'Ready';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.12),
                blurRadius: 12,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          statusText,
          style: const TextStyle(
            color: PdfEditorTheme.muted,
            fontSize: 12,
          ),
        ),
        if (state.isProcessing) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            height: 3,
            child: LinearProgressIndicator(
              value: state.exportProgress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                PdfEditorTheme.accent,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }
}
