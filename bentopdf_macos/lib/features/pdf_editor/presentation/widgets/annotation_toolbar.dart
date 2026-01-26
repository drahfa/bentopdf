import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_editor_provider.dart';
import '../../../../shared/services/canvas_annotation_service.dart';
import 'stamp_dialog.dart';
import 'signature_dialog.dart';

class AnnotationToolbar extends ConsumerWidget {
  const AnnotationToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildToolButton(
            context,
            icon: Icons.select_all,
            label: 'Select',
            isSelected: state.selectedTool == AnnotationTool.none,
            onPressed: () => notifier.selectTool(AnnotationTool.none),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.highlight,
            label: 'Highlight',
            isSelected: state.selectedTool == AnnotationTool.highlight,
            onPressed: () => notifier.selectTool(AnnotationTool.highlight),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.brush,
            label: 'Draw',
            isSelected: state.selectedTool == AnnotationTool.ink,
            onPressed: () => notifier.selectTool(AnnotationTool.ink),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.rectangle_outlined,
            label: 'Rectangle',
            isSelected: state.selectedTool == AnnotationTool.rectangle,
            onPressed: () => notifier.selectTool(AnnotationTool.rectangle),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.circle_outlined,
            label: 'Circle',
            isSelected: state.selectedTool == AnnotationTool.circle,
            onPressed: () => notifier.selectTool(AnnotationTool.circle),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.comment,
            label: 'Comment',
            isSelected: state.selectedTool == AnnotationTool.comment,
            onPressed: () => notifier.selectTool(AnnotationTool.comment),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.edit,
            label: 'Signature',
            isSelected: state.selectedTool == AnnotationTool.signature,
            onPressed: () => _showSignatureDialog(context, ref),
          ),
          const SizedBox(width: 8),
          _buildToolButton(
            context,
            icon: Icons.image,
            label: 'Stamp',
            isSelected: state.selectedTool == AnnotationTool.stamp,
            onPressed: () => _showStampDialog(context, ref),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: state.selectedColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              onTap: () => _showColorPicker(context, ref),
              child: const Icon(Icons.colorize, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          if (state.selectedTool == AnnotationTool.ink ||
              state.selectedTool == AnnotationTool.rectangle ||
              state.selectedTool == AnnotationTool.circle) ...[
            const Text('Thickness:'),
            const SizedBox(width: 8),
            SizedBox(
              width: 150,
              child: Slider(
                value: state.thickness,
                min: 1,
                max: 20,
                divisions: 19,
                label: state.thickness.toStringAsFixed(0),
                onChanged: (value) => notifier.changeThickness(value),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: () {
              final newZoom = (state.zoomLevel - 0.1).clamp(0.4, 3.0);
              notifier.changeZoom(newZoom);
            },
          ),
          SizedBox(
            width: 120,
            child: Slider(
              value: state.zoomLevel,
              min: 0.4,
              max: 3.0,
              divisions: 26,
              label: '${(state.zoomLevel * 100).toInt()}%',
              onChanged: (value) => notifier.changeZoom(value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: () {
              final newZoom = (state.zoomLevel + 0.1).clamp(0.4, 3.0);
              notifier.changeZoom(newZoom);
            },
          ),
          TextButton(
            onPressed: () => notifier.changeZoom(1.0),
            child: Text('${(state.zoomLevel * 100).toInt()}%'),
          ),
          const SizedBox(width: 8),
          if (state.selectedAnnotationId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected annotation',
              onPressed: () => notifier.deleteSelectedAnnotation(),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          tooltip: label,
          onPressed: onPressed,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          style: IconButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : null,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(pdfEditorProvider.notifier);
    final colors = [
      Colors.yellow,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return InkWell(
              onTap: () {
                notifier.changeColor(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
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
}
