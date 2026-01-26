import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../providers/pdf_editor_provider.dart';
import '../widgets/pdf_canvas_viewer.dart';
import '../widgets/pdf_editor_header.dart';
import '../widgets/pdf_pages_sidebar.dart';
import '../widgets/pdf_editor_toolbar.dart';
import '../widgets/pdf_controls_bar.dart';
import '../widgets/pdf_inspector_sidebar.dart';
import '../widgets/pdf_editor_footer.dart';
import '../../../../core/di/service_providers.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';

class PdfEditorPage extends ConsumerStatefulWidget {
  const PdfEditorPage({super.key});

  @override
  ConsumerState<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends ConsumerState<PdfEditorPage> {
  Future<void> _loadPdf() async {
    final fileService = ref.read(fileServiceProvider);
    final filePath = await fileService.pickPdfFile();

    if (filePath != null) {
      final notifier = ref.read(pdfEditorProvider.notifier);
      await notifier.loadPdf(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfEditorProvider);

    return Scaffold(
      backgroundColor: PdfEditorTheme.bg,
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: state.document == null
            ? _buildEmptyState(context)
            : _buildEditorLayout(state),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF070A14),
          PdfEditorTheme.bg,
        ],
      ),
      image: DecorationImage(
        image: const AssetImage('assets/images/bg_gradient.png'),
        fit: BoxFit.cover,
        opacity: 0.3,
        onError: (exception, stackTrace) {
          // Fallback if image doesn't exist
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        // Radial gradient overlay
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
        Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildDropZone(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
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
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PDF Editor',
                        style: TextStyle(
                          color: PdfEditorTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Annotate & Edit PDFs',
                        style: TextStyle(
                          color: PdfEditorTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return DropTarget(
      onDragDone: (details) async {
        final pdfFiles = details.files
            .where((file) => file.path.toLowerCase().endsWith('.pdf'))
            .toList();

        if (pdfFiles.isNotEmpty) {
          final notifier = ref.read(pdfEditorProvider.notifier);
          await notifier.loadPdf(pdfFiles.first.path);
        }
      },
      child: Center(
        child: GlassPanel(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: PdfEditorTheme.accent.withOpacity(0.12),
                    border: Border.all(
                      color: PdfEditorTheme.accent.withOpacity(0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    size: 64,
                    color: PdfEditorTheme.accent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Drag and drop a PDF file here',
                  style: TextStyle(
                    color: PdfEditorTheme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'or',
                  style: TextStyle(
                    color: PdfEditorTheme.muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _loadPdf,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open, size: 20, color: PdfEditorTheme.text),
                          SizedBox(width: 10),
                          Text(
                            'Select PDF File',
                            style: TextStyle(
                              color: PdfEditorTheme.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorLayout(PdfEditorState state) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header
          PdfEditorHeader(onLoadPdf: _loadPdf),
          const SizedBox(height: 12),

          // Main content area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left sidebar - Pages
                const SizedBox(
                  width: 160,
                  child: PdfPagesSidebar(),
                ),
                const SizedBox(width: 12),

                // Main canvas area
                Expanded(
                  child: Column(
                    children: [
                      // Toolbar
                      const PdfEditorToolbar(),
                      const SizedBox(height: 12),

                      // Canvas
                      const Expanded(
                        child: PdfCanvasViewer(),
                      ),
                      const SizedBox(height: 12),

                      // Page and Zoom controls
                      const PdfControlsBar(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right sidebar - Inspector
                const SizedBox(
                  width: 240,
                  child: PdfInspectorSidebar(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Footer
          const PdfEditorFooter(),
        ],
      ),
    );
  }
}
