import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pdf_editor_theme.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

class GlassPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == AppThemeMode.dark;

    final decoration = isDark
        ? PdfEditorTheme.glassPanelDecoration
        : PdfEditorThemeLight.glassPanelDecoration;
    final radius = borderRadius ?? (isDark ? PdfEditorTheme.radius : PdfEditorThemeLight.radius);
    final blur = isDark ? PdfEditorTheme.blur : PdfEditorThemeLight.blur;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: decoration.copyWith(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
