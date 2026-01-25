import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:pdfcow/core/theme/pdf_editor_theme.dart';
import 'package:pdfcow/shared/widgets/glass_panel.dart';

class PdfFileSelector extends StatefulWidget {
  final String? selectedFilePath;
  final int? pageCount;
  final VoidCallback onSelectFile;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;

  const PdfFileSelector({
    super.key,
    required this.selectedFilePath,
    this.pageCount,
    required this.onSelectFile,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
  });

  @override
  State<PdfFileSelector> createState() => _PdfFileSelectorState();
}

class _PdfFileSelectorState extends State<PdfFileSelector> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedFilePath != null) {
      return _buildSelectedFile(context);
    }

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        final pdfFiles = details.files
            .where((file) => file.path.toLowerCase().endsWith('.pdf'))
            .toList();

        if (pdfFiles.isNotEmpty) {
          widget.onSelectFile();
        }
      },
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
                child: Icon(
                  Icons.upload_file,
                  size: 64,
                  color: PdfEditorTheme.accent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Drag and drop a PDF file here',
                style: const TextStyle(
                  color: PdfEditorTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
                  onTap: widget.onSelectFile,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_open, size: 20, color: PdfEditorTheme.text),
                        SizedBox(width: 10),
                        Text(
                          'Select Files',
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
    );
  }

  Widget _buildSelectedFile(BuildContext context) {
    return GlassPanel(
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
              child: Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: PdfEditorTheme.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.selectedFilePath!.split('/').last,
              style: const TextStyle(
                color: PdfEditorTheme.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.pageCount != null) ...[
              const SizedBox(height: 8),
              Text(
                '${widget.pageCount} pages',
                style: const TextStyle(
                  color: PdfEditorTheme.muted,
                  fontSize: 13,
                ),
              ),
            ],
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
                onTap: widget.onSelectFile,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: PdfEditorTheme.buttonDecoration(isPrimary: true),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_open, size: 20, color: PdfEditorTheme.text),
                      SizedBox(width: 10),
                      Text(
                        'Select Files',
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
    );
  }
}
