import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/shared/models/tool_info.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';

class ToolCard extends StatefulWidget {
  final ToolInfo tool;

  const ToolCard({
    super.key,
    required this.tool,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.tool.isAvailable
                ? () {
                    context.push(widget.tool.route);
                  }
                : null,
            borderRadius: BorderRadius.circular(PdfEditorTheme.radius),
            child: Container(
              decoration: BoxDecoration(
                gradient: PdfEditorTheme.glassGradient,
                border: Border.all(
                  color: _isHovered
                      ? PdfEditorTheme.accent.withOpacity(0.35)
                      : Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(PdfEditorTheme.radius),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? PdfEditorTheme.accent.withOpacity(0.15)
                        : Colors.black.withOpacity(0.25),
                    blurRadius: _isHovered ? 35 : 30,
                    offset: Offset(0, _isHovered ? 15 : 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.tool.isAvailable
                            ? PdfEditorTheme.accent.withOpacity(0.12)
                            : Colors.black.withOpacity(0.12),
                        border: Border.all(
                          color: widget.tool.isAvailable
                              ? PdfEditorTheme.accent.withOpacity(0.25)
                              : Colors.white.withOpacity(0.10),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.tool.icon,
                        size: 28,
                        color: widget.tool.isAvailable
                            ? PdfEditorTheme.accent
                            : PdfEditorTheme.muted2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.tool.name.tr(),
                      style: TextStyle(
                        color: widget.tool.isAvailable
                            ? PdfEditorTheme.text
                            : PdfEditorTheme.muted2,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.tool.description.tr(),
                      style: TextStyle(
                        color: widget.tool.isAvailable
                            ? PdfEditorTheme.muted
                            : PdfEditorTheme.muted2,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
