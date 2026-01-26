import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../../shared/services/canvas_annotation_service.dart';
import '../providers/pdf_editor_provider.dart';
import 'stamp_dialog.dart';
import 'signature_dialog.dart';
import 'text_dialog.dart';

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
                    icon: state.selectedTool == AnnotationTool.circle
                        ? Icons.circle_outlined
                        : Icons.rectangle_outlined,
                    isActive: state.selectedTool == AnnotationTool.rectangle ||
                        state.selectedTool == AnnotationTool.circle,
                    onPressed: () => notifier.selectTool(AnnotationTool.rectangle),
                  ),
                  _buildTool(
                    label: 'Stamp',
                    icon: Icons.image,
                    isActive: state.selectedTool == AnnotationTool.stamp,
                    onPressed: () => _showStampDialog(context, ref),
                  ),
                  _buildTool(
                    label: 'Signature',
                    icon: Icons.edit,
                    isActive: state.selectedTool == AnnotationTool.signature,
                    onPressed: () => _showSignatureDialog(context, ref),
                  ),
                  _buildTool(
                    label: 'Add Text',
                    icon: Icons.text_fields,
                    isActive: state.selectedTool == AnnotationTool.text,
                    onPressed: () => _showTextDialog(context, ref),
                  ),
                  if (state.selectedTool == AnnotationTool.ink) ...[
                    _buildDivider(),
                    _buildThicknessControl(state, notifier),
                    _buildColorPicker(state, notifier),
                  ],
                  if (state.selectedTool == AnnotationTool.rectangle ||
                      state.selectedTool == AnnotationTool.circle) ...[
                    _buildDivider(),
                    _buildShapeTypeSelector(state, notifier),
                    _buildThicknessControl(state, notifier),
                    _buildColorPicker(state, notifier),
                  ],
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

  Widget _buildShapeTypeSelector(PdfEditorState state, PdfEditorNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShapeOption(
            icon: Icons.rectangle_outlined,
            label: 'Rectangle',
            isSelected: state.selectedTool == AnnotationTool.rectangle,
            onTap: () => notifier.selectTool(AnnotationTool.rectangle),
          ),
          const SizedBox(width: 4),
          _buildShapeOption(
            icon: Icons.circle_outlined,
            label: 'Circle',
            isSelected: state.selectedTool == AnnotationTool.circle,
            onTap: () => notifier.selectTool(AnnotationTool.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? PdfEditorTheme.accent.withOpacity(0.2)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? PdfEditorTheme.accent
                  : Colors.white.withOpacity(0.15),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? PdfEditorTheme.accent : PdfEditorTheme.text,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? PdfEditorTheme.accent : PdfEditorTheme.text,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThicknessControl(PdfEditorState state, PdfEditorNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.line_weight,
            size: 14,
            color: PdfEditorTheme.text,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Slider(
              value: state.thickness,
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: PdfEditorTheme.accent,
              inactiveColor: Colors.white.withOpacity(0.2),
              onChanged: (value) => notifier.changeThickness(value),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${state.thickness.toInt()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PdfEditorTheme.text,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(PdfEditorState state, PdfEditorNotifier notifier) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((color) {
          final isSelected = state.selectedColor.value == color.value;
          return GestureDetector(
            onTap: () => notifier.changeColor(color),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? PdfEditorTheme.accent
                      : Colors.white.withOpacity(0.3),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: PdfEditorTheme.accent.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showStampDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Uint8List>(
      context: context,
      builder: (context) => const StampDialog(),
    );

    if (result != null) {
      final notifier = ref.read(pdfEditorProvider.notifier);
      notifier.startStampPlacement(result);
    }
  }

  Future<void> _showSignatureDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Uint8List>(
      context: context,
      builder: (context) => const SignatureDialog(),
    );

    if (result != null) {
      final notifier = ref.read(pdfEditorProvider.notifier);
      notifier.startSignaturePlacement(result);
    }
  }

  Future<void> _showTextDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const TextDialog(),
    );

    if (result != null) {
      final notifier = ref.read(pdfEditorProvider.notifier);
      notifier.startTextPlacement(
        result['text'] as String,
        result['fontSize'] as double,
        result['color'] as Color,
        result['fontWeight'] as FontWeight,
      );
    }
  }
}
