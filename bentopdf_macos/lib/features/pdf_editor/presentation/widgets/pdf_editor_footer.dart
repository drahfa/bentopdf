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

            // Orientation info
            if (state.pageOrientations.isNotEmpty) ...[
              const SizedBox(width: 20),
              _buildOrientationInfo(state),
            ],

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

  Widget _buildOrientationInfo(PdfEditorState state) {
    final currentPageOrientation = state.pageOrientations
        .where((o) => o.pageNumber == state.currentPageNumber)
        .firstOrNull;

    if (currentPageOrientation == null) return const SizedBox.shrink();

    IconData orientationIcon;
    switch (currentPageOrientation.orientation) {
      case PageOrientation.portrait:
        orientationIcon = Icons.stay_primary_portrait;
        break;
      case PageOrientation.landscape:
        orientationIcon = Icons.stay_primary_landscape;
        break;
      case PageOrientation.square:
        orientationIcon = Icons.crop_square;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            orientationIcon,
            size: 14,
            color: PdfEditorTheme.muted,
          ),
          const SizedBox(width: 6),
          Text(
            currentPageOrientation.orientationName,
            style: const TextStyle(
              color: PdfEditorTheme.muted,
              fontSize: 11,
            ),
          ),
          if (currentPageOrientation.rotation != 0) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.rotate_90_degrees_ccw,
              size: 12,
              color: PdfEditorTheme.accent,
            ),
            Text(
              '${currentPageOrientation.rotation}°',
              style: const TextStyle(
                color: PdfEditorTheme.accent,
                fontSize: 10,
              ),
            ),
          ],
          if (state.hasMixedOrientations) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: PdfEditorTheme.warn.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Mixed',
                style: TextStyle(
                  color: PdfEditorTheme.warn,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }
}
