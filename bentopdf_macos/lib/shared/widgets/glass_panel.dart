import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/pdf_editor_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? PdfEditorTheme.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: PdfEditorTheme.blur, sigmaY: PdfEditorTheme.blur),
        child: Container(
          decoration: PdfEditorTheme.glassPanelDecoration.copyWith(
            borderRadius: BorderRadius.circular(borderRadius ?? PdfEditorTheme.radius),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
