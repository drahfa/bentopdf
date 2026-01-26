import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/shared/models/tool_info.dart';
import 'package:pdfcow/features/home/presentation/widgets/tool_card.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: PdfEditorTheme.backgroundDecoration,
        child: Stack(
          children: [
            // Radial gradient overlays
            Positioned(
              top: -200,
              left: -100,
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
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PdfEditorTheme.accent2.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        _buildHeroSection(context),
                        const SizedBox(height: 48),
                        _buildToolsGrid(),
                      ],
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: PdfEditorTheme.glassGradient,
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(PdfEditorTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xF27C5CFF),
                  Color(0xD922C55E),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: PdfEditorTheme.accent.withOpacity(0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.picture_as_pdf,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Brand name
          const Text(
            'SitiPDF',
            style: TextStyle(
              color: PdfEditorTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          // Language selector
          _buildLanguageSelector(context),
          const SizedBox(width: 12),
          // Settings button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/settings'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings,
                  size: 20,
                  color: PdfEditorTheme.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'tr':
        return '🇹🇷';
      case 'vi':
        return '🇻🇳';
      case 'zh':
        return locale.countryCode == 'TW' ? '🇹🇼' : '🇨🇳';
      default:
        return '🌐';
    }
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'tr':
        return 'Türkçe';
      case 'vi':
        return 'Tiếng Việt';
      case 'zh':
        return locale.countryCode == 'TW' ? '繁體中文' : '简体中文';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final currentLocale = context.locale;
    final supportedLocales = context.supportedLocales;

    return PopupMenuButton<Locale>(
      tooltip: 'Change Language',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
      ),
      color: const Color(0xFF1a1f35),
      itemBuilder: (context) {
        return supportedLocales.map((locale) {
          final isSelected = locale == currentLocale;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(
                  _getLanguageFlag(locale),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  _getLanguageName(locale),
                  style: TextStyle(
                    color: isSelected ? PdfEditorTheme.accent : PdfEditorTheme.text,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check,
                    size: 16,
                    color: PdfEditorTheme.accent,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      onSelected: (locale) async {
        await context.setLocale(locale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.12),
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLanguageFlag(currentLocale),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: PdfEditorTheme.text.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'app.tagline'.tr(),
          style: const TextStyle(
            color: PdfEditorTheme.text,
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'app.subtitle'.tr(),
          style: TextStyle(
            color: PdfEditorTheme.muted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildToolsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 230).floor().clamp(2, 6);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemCount: ToolsConfig.tools.length,
          itemBuilder: (context, index) {
            final tool = ToolsConfig.tools[index];
            return ToolCard(tool: tool);
          },
        );
      },
    );
  }
}
