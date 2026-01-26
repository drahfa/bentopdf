import 'package:flutter/material.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';

class HighlightDialog extends StatefulWidget {
  final Color? initialColor;
  final double? initialOpacity;

  const HighlightDialog({
    super.key,
    this.initialColor,
    this.initialOpacity,
  });

  @override
  State<HighlightDialog> createState() => _HighlightDialogState();
}

class _HighlightDialogState extends State<HighlightDialog> {
  late Color _highlightColor;
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _highlightColor = widget.initialColor ?? Colors.yellow;
    _opacity = widget.initialOpacity ?? 0.3;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialColor != null ? 'Edit Highlight' : 'Add Highlight',
                style: const TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Color',
                style: TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                  Colors.cyan,
                ].map((color) {
                  final isSelected = _highlightColor.value == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _highlightColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: isSelected
                              ? PdfEditorTheme.accent
                              : Colors.white.withOpacity(0.3),
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Transparency',
                style: TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _opacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      activeColor: PdfEditorTheme.accent,
                      inactiveColor: Colors.white.withOpacity(0.2),
                      onChanged: (value) {
                        setState(() {
                          _opacity = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(_opacity * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PdfEditorTheme.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: _highlightColor.withOpacity(_opacity),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: PdfEditorTheme.muted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop({
                          'color': _highlightColor,
                          'opacity': _opacity,
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                        child: Text(
                          widget.initialColor != null ? 'Update' : 'Apply',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
