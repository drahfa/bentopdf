import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class PdfEditorPage extends ConsumerStatefulWidget {
  const PdfEditorPage({super.key});

  @override
  ConsumerState<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends ConsumerState<PdfEditorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdf();
    });
  }

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
            ? _buildEmptyState()
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: PdfEditorTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: PdfEditorTheme.accentShadow,
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No PDF loaded',
            style: TextStyle(
              color: PdfEditorTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Open a PDF file to start editing',
            style: TextStyle(
              color: PdfEditorTheme.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.folder_open),
            label: const Text('Open PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PdfEditorTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: _loadPdf,
          ),
        ],
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
                  width: 190,
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
