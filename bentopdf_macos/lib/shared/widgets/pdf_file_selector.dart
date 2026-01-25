import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';

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
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragging
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _isDragging
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isDragging ? Icons.file_download : Icons.upload_file,
              size: 48,
              color: _isDragging
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isDragging
                  ? 'Drop PDF here'
                  : widget.emptyStateTitle ?? 'Select or drop PDF file',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (!_isDragging) ...[
              const SizedBox(height: 8),
              Text(
                widget.emptyStateSubtitle ??
                    'Drag and drop a PDF file here, or click below',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onSelectFile,
                icon: const Icon(Icons.file_open),
                label: const Text('Choose PDF File'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedFilePath!.split('/').last,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.pageCount != null)
                  Text(
                    '${widget.pageCount} pages',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: widget.onSelectFile,
            icon: const Icon(Icons.refresh),
            label: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
