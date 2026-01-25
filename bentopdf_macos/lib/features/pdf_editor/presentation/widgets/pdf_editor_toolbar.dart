import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/services/canvas_annotation_service.dart';
import '../providers/pdf_editor_provider.dart';

class PdfEditorToolbar extends ConsumerWidget {
  const PdfEditorToolbar({super.key});

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
          children: [
            // Annotation tools (wrappable)
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildTool(
                    label: 'Pan',
                    icon: Icons.pan_tool,
                    isActive: state.selectedTool == AnnotationTool.pan,
                    onPressed: () => notifier.selectTool(AnnotationTool.pan),
                  ),
                  _buildTool(
                    label: 'Select',
                    icon: Icons.touch_app,
                    isActive: state.selectedTool == AnnotationTool.none,
                    onPressed: () => notifier.selectTool(AnnotationTool.none),
                  ),
                  _buildTool(
                    label: 'Highlight',
                    icon: Icons.highlight,
                    isActive: state.selectedTool == AnnotationTool.highlight,
                    onPressed: () => notifier.selectTool(AnnotationTool.highlight),
                  ),
                  _buildTool(
                    label: 'Draw',
                    icon: Icons.brush,
                    isActive: state.selectedTool == AnnotationTool.ink,
                    onPressed: () => notifier.selectTool(AnnotationTool.ink),
                  ),
                  _buildTool(
                    label: 'Shape',
                    icon: Icons.rectangle_outlined,
                    isActive: state.selectedTool == AnnotationTool.rectangle ||
                        state.selectedTool == AnnotationTool.circle,
                    onPressed: () => notifier.selectTool(AnnotationTool.rectangle),
                  ),
                  _buildTool(
                    label: 'Stamp',
                    icon: Icons.image,
                    isActive: state.selectedTool == AnnotationTool.stamp,
                    onPressed: () => notifier.selectTool(AnnotationTool.stamp),
                  ),
                  _buildTool(
                    label: 'Signature',
                    icon: Icons.edit,
                    isActive: state.selectedTool == AnnotationTool.signature,
                    onPressed: () => notifier.selectTool(AnnotationTool.signature),
                  ),
                  if (state.selectedAnnotationId != null) ...[
                    _buildDivider(),
                    _buildTool(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      onPressed: () => notifier.deleteSelectedAnnotation(),
                      isDanger: true,
                    ),
                  ],
                ],
              ),
            ),
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
    bool isActive = false,
    bool isDanger = false,
    bool isSmall = false,
  }) {
    final decoration = isDanger
        ? BoxDecoration(
            color: PdfEditorTheme.danger.withOpacity(0.14),
            border: Border.all(
              color: PdfEditorTheme.danger.withOpacity(0.55),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          )
        : PdfEditorTheme.toolDecoration(isActive: isActive);

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
                color: isDanger
                    ? PdfEditorTheme.danger
                    : (isActive ? PdfEditorTheme.accent : PdfEditorTheme.text),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isDanger
                        ? PdfEditorTheme.danger
                        : (isActive ? PdfEditorTheme.text : PdfEditorTheme.text),
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

}
