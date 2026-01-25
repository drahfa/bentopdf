import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: PdfEditorTheme.backgroundDecoration,
        child: Stack(
          children: [
            // Radial gradient overlay
            Positioned(
              top: -200,
              right: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PdfEditorTheme.accent.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Settings'),
                            const SizedBox(height: 24),
                            _buildAppearanceSection(),
                            const SizedBox(height: 24),
                            _buildLanguageSection(context),
                            const SizedBox(height: 24),
                            _buildAboutSection(),
                            const SizedBox(height: 40),
                            _buildAttribution(),
                          ],
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Back button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: PdfEditorTheme.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PdfEditorTheme.accent.withOpacity(0.14),
                      border: Border.all(
                        color: PdfEditorTheme.accent.withOpacity(0.25),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 20,
                      color: PdfEditorTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: PdfEditorTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: PdfEditorTheme.text,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PdfEditorTheme.accent.withOpacity(0.14),
                    border: Border.all(
                      color: PdfEditorTheme.accent.withOpacity(0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    size: 20,
                    color: PdfEditorTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Appearance',
                  style: TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Theme',
              'Dark mode (Glassmorphism)',
              Icons.dark_mode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PdfEditorTheme.accent2.withOpacity(0.14),
                    border: Border.all(
                      color: PdfEditorTheme.accent2.withOpacity(0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language,
                    size: 20,
                    color: PdfEditorTheme.accent2,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Language',
                  style: TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'App Language',
              context.locale.languageCode == 'en' ? 'English' : 'Malay',
              Icons.translate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PdfEditorTheme.accent.withOpacity(0.14),
                    border: Border.all(
                      color: PdfEditorTheme.accent.withOpacity(0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: PdfEditorTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'About',
                  style: TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Version',
              '1.1.0',
              Icons.tag,
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              'License',
              'Open Source',
              Icons.code,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: PdfEditorTheme.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: PdfEditorTheme.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttribution() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PdfEditorTheme.accent.withOpacity(0.08),
            PdfEditorTheme.accent2.withOpacity(0.06),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(PdfEditorTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Made with',
                style: TextStyle(
                  color: PdfEditorTheme.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '❤️',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              const Text(
                'by',
                style: TextStyle(
                  color: PdfEditorTheme.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ahmad Faisal Mohamad Ayob\nSiti Nor Khadijah Addis\nAhmad Aiman Ahmad Faisal\nAhmad Adib Ahmad Faisal',
            style: TextStyle(
              color: PdfEditorTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'VSG Labs',
            style: TextStyle(
              color: PdfEditorTheme.accent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
