import 'package:flutter/material.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';

class TextDialog extends StatefulWidget {
  final String? initialText;
  final double? initialFontSize;
  final Color? initialColor;
  final FontWeight? initialFontWeight;

  const TextDialog({
    super.key,
    this.initialText,
    this.initialFontSize,
    this.initialColor,
    this.initialFontWeight,
  });

  @override
  State<TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
  late final TextEditingController _textController;
  late double _fontSize;
  late Color _textColor;
  late FontWeight _fontWeight;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    _fontSize = widget.initialFontSize ?? 16.0;
    _textColor = widget.initialColor ?? Colors.black;
    _fontWeight = widget.initialFontWeight ?? FontWeight.normal;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
                widget.initialText != null ? 'Edit Text' : 'Add Text',
                style: const TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _textController,
                autofocus: true,
                maxLines: 3,
                style: TextStyle(
                  color: _textColor,
                  fontSize: _fontSize,
                  fontWeight: _fontWeight,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter text...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: PdfEditorTheme.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Font Size',
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
                      value: _fontSize,
                      min: 8,
                      max: 48,
                      divisions: 40,
                      activeColor: PdfEditorTheme.accent,
                      inactiveColor: Colors.white.withOpacity(0.2),
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_fontSize.toInt()}',
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
              Row(
                children: [
                  const Text(
                    'Color',
                    style: TextStyle(
                      color: PdfEditorTheme.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...[
                    Colors.black,
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    PdfEditorTheme.accent,
                  ].map((color) {
                    final isSelected = _textColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _textColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: isSelected
                                ? PdfEditorTheme.accent
                                : Colors.white.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _fontWeight = _fontWeight == FontWeight.normal
                            ? FontWeight.bold
                            : FontWeight.normal;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _fontWeight == FontWeight.bold
                            ? PdfEditorTheme.accent.withOpacity(0.2)
                            : Colors.black.withOpacity(0.18),
                        border: Border.all(
                          color: _fontWeight == FontWeight.bold
                              ? PdfEditorTheme.accent
                              : Colors.white.withOpacity(0.10),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'B',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
                        if (_textController.text.isNotEmpty) {
                          Navigator.of(context).pop({
                            'text': _textController.text,
                            'fontSize': _fontSize,
                            'color': _textColor,
                            'fontWeight': _fontWeight,
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                        child: Text(
                          widget.initialText != null ? 'Update' : 'Add Text',
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
