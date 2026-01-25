import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../providers/pdf_editor_provider.dart';

class PdfControlsBar extends ConsumerWidget {
  const PdfControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    return GlassPanel(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.10),
          borderRadius: BorderRadius.circular(PdfEditorTheme.radius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Page navigation
            _buildToolGroup([
              _buildTool(
                label: '',
                icon: Icons.chevron_left,
                onPressed: state.currentPageNumber > 1
                    ? () => notifier.previousPage()
                    : null,
                isSmall: true,
              ),
              _buildPageIndicator(state),
              _buildTool(
                label: '',
                icon: Icons.chevron_right,
                onPressed: state.currentPageNumber < state.totalPages
                    ? () => notifier.nextPage()
                    : null,
                isSmall: true,
              ),
            ]),

            _buildDivider(),

            // Zoom controls
            _buildToolGroup([
              _buildTool(
                label: '',
                icon: Icons.remove,
                onPressed: () {
                  final newZoom = (state.zoomLevel - 0.1).clamp(0.5, 3.0);
                  notifier.changeZoom(newZoom);
                },
                isSmall: true,
              ),
              _buildZoomIndicator(state, notifier),
              _buildTool(
                label: '',
                icon: Icons.add,
                onPressed: () {
                  final newZoom = (state.zoomLevel + 0.1).clamp(0.5, 3.0);
                  notifier.changeZoom(newZoom);
                },
                isSmall: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildToolGroup(List<Widget> tools) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tools
          .map((tool) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: tool,
              ))
          .toList(),
    );
  }

  Widget _buildTool({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isSmall = false,
  }) {
    final decoration = PdfEditorTheme.toolDecoration();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 12,
            vertical: 8,
          ),
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: PdfEditorTheme.text,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildPageIndicator(PdfEditorState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: PdfEditorTheme.toolDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Page',
            style: TextStyle(
              color: PdfEditorTheme.text.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${state.currentPageNumber}',
            style: const TextStyle(
              color: PdfEditorTheme.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' / ',
            style: TextStyle(
              color: PdfEditorTheme.text.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
          Text(
            '${state.totalPages}',
            style: TextStyle(
              color: PdfEditorTheme.text.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomIndicator(PdfEditorState state, PdfEditorNotifier notifier) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => notifier.changeZoom(1.0),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: PdfEditorTheme.toolDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Zoom',
                style: TextStyle(
                  color: PdfEditorTheme.text.withOpacity(0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(state.zoomLevel * 100).toInt()}%',
                style: const TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
