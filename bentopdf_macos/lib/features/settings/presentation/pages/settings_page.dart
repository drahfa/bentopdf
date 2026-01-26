import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';
import 'package:pdfcow/features/settings/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
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
                            // _buildAppearanceSection(ref, settings),
                            // const SizedBox(height: 24),
                            _buildLanguageSection(context, ref),
                            const SizedBox(height: 24),
                            _buildAboutSection(context),
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

  Widget _buildAppearanceSection(WidgetRef ref, SettingsState settings) {
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
            _buildThemeSelector(ref, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(WidgetRef ref, SettingsState settings) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settings.themeMode == AppThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: 18,
                color: PdfEditorTheme.muted,
              ),
              const SizedBox(width: 12),
              const Text(
                'Theme',
                style: TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  ref,
                  AppThemeMode.light,
                  'Light Theme',
                  Icons.light_mode,
                  settings.themeMode == AppThemeMode.light,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  ref,
                  AppThemeMode.dark,
                  'Dark Theme',
                  Icons.dark_mode,
                  settings.themeMode == AppThemeMode.dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    WidgetRef ref,
    AppThemeMode mode,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(settingsProvider.notifier).setThemeMode(mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PdfEditorTheme.accent.withOpacity(0.30),
                      PdfEditorTheme.accent.withOpacity(0.20),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.black.withOpacity(0.12),
            border: Border.all(
              color: isSelected
                  ? PdfEditorTheme.accent.withOpacity(0.50)
                  : Colors.white.withOpacity(0.08),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? PdfEditorTheme.text : PdfEditorTheme.muted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? PdfEditorTheme.text : PdfEditorTheme.muted,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, WidgetRef ref) {
    final languageMap = {
      'en': 'English',
      'de': 'Deutsch (German)',
      'es': 'Español (Spanish)',
      'fr': 'Français (French)',
      'it': 'Italiano (Italian)',
      'pt': 'Português (Portuguese)',
      'tr': 'Türkçe (Turkish)',
      'vi': 'Tiếng Việt (Vietnamese)',
      'zh': '中文 (Chinese Simplified)',
      'zh-TW': '繁體中文 (Chinese Traditional)',
    };

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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.translate,
                        size: 18,
                        color: PdfEditorTheme.muted,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'App Language',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        border: Border.all(
                          color: PdfEditorTheme.accent2.withOpacity(0.25),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: context.locale.toString(),
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1a1f35),
                          style: const TextStyle(
                            color: PdfEditorTheme.text,
                            fontSize: 13,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: PdfEditorTheme.accent2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          items: languageMap.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  color: PdfEditorTheme.text,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newLocale) {
                            if (newLocale != null) {
                              final localeParts = newLocale.split('-');
                              context.setLocale(
                                Locale(
                                  localeParts[0],
                                  localeParts.length > 1
                                      ? localeParts[1]
                                      : null,
                                ),
                              );
                            }
                          },
                        ),
                      ),
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

  Widget _buildAboutSection(BuildContext context) {
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
              '1.4.0',
              Icons.tag,
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              'Published by',
              'VSG Labs',
              Icons.business,
            ),
            const SizedBox(height: 12),
            _buildSettingItemWithSubtitle(
              'License',
              'Commercial License',
              'Proprietary software. All rights reserved. Unauthorized distribution, modification, or commercial use is prohibited.',
              Icons.verified_user,
            ),
            const SizedBox(height: 12),
            _buildClickableSettingItem(
              context,
              'Open Source Licenses',
              'View third-party software credits',
              Icons.code,
              () {
                showLicensePage(
                  context: context,
                  applicationName: 'SitiPDF',
                  applicationVersion: '1.4.0',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  applicationLegalese: '© 2026 VSG Labs. All rights reserved.',
                );
              },
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

  Widget _buildSettingItemWithSubtitle(
      String title, String value, String subtitle, IconData icon) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: PdfEditorTheme.muted.withOpacity(0.8),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                color: PdfEditorTheme.accent,
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
                      subtitle,
                      style: TextStyle(
                        color: PdfEditorTheme.muted.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: PdfEditorTheme.muted.withOpacity(0.5),
              ),
            ],
          ),
        ),
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
              fontWeight: FontWeight.w400,
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
