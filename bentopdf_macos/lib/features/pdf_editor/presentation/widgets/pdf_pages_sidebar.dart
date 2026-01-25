import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/pdf_editor_theme.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../providers/pdf_editor_provider.dart';

class PdfPagesSidebar extends ConsumerWidget {
  const PdfPagesSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEditorProvider);
    final notifier = ref.read(pdfEditorProvider.notifier);

    return GlassPanel(
      child: Column(
        children: [
          // Header
          _buildHeader(state),

          // Page thumbnails
          Expanded(
            child: _buildPageThumbnails(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PdfEditorState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pages',
            style: PdfEditorTheme.headingStyle,
          ),
          Text(
            '${state.totalPages} pages',
            style: PdfEditorTheme.mutedStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildPageThumbnails(
    PdfEditorState state,
    PdfEditorNotifier notifier,
  ) {
    if (state.totalPages == 0) {
      return const Center(
        child: Text(
          'No pages',
          style: PdfEditorTheme.mutedStyle,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: state.totalPages,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        final isActive = pageNumber == state.currentPageNumber;

        return _buildPageThumbnail(
          pageNumber: pageNumber,
          isActive: isActive,
          onTap: () => notifier.goToPage(pageNumber),
        );
      },
    );
  }

  Widget _buildPageThumbnail({
    required int pageNumber,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? PdfEditorTheme.accent.withOpacity(0.12)
                : Colors.black.withOpacity(0.18),
            border: Border.all(
              color: isActive
                  ? PdfEditorTheme.accent.withOpacity(0.55)
                  : Colors.white.withOpacity(0.10),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: PdfEditorTheme.accent.withOpacity(0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Thumbnail preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: PdfEditorTheme.muted.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              // Page label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page $pageNumber',
                      style: TextStyle(
                        color: isActive
                            ? PdfEditorTheme.text
                            : PdfEditorTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
