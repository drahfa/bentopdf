import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_providers.dart';

class SignatureDialog extends ConsumerStatefulWidget {
  const SignatureDialog({super.key});

  @override
  ConsumerState<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends ConsumerState<SignatureDialog> {
  final List<Offset> _points = [];
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Add Signature',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTabButton('Draw', 0),
                const SizedBox(width: 8),
                _buildTabButton('Upload', 1),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedTab == 0
                  ? _buildDrawTab()
                  : _buildUploadTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () => setState(() => _selectedTab = index),
      child: Text(label),
    );
  }

  Widget _buildDrawTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
            ),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _points.add(details.localPosition);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _points.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _points.add(Offset.infinite);
                });
              },
              child: CustomPaint(
                painter: _SignaturePainter(_points),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _points.clear();
                });
              },
              child: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _points.isEmpty ? null : _saveDrawnSignature,
              child: const Text('Add Signature'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.upload_file, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Upload a signature image',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Supported formats: PNG, JPG',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.folder_open),
          label: const Text('Choose File'),
          onPressed: _uploadSignature,
        ),
      ],
    );
  }

  Future<void> _saveDrawnSignature() async {
    if (_points.isEmpty) return;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != Offset.infinite &&
            _points[i + 1] != Offset.infinite) {
          canvas.drawLine(_points[i], _points[i + 1], paint);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 200);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        Navigator.pop(context, byteData.buffer.asUint8List());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save signature: $e')),
        );
      }
    }
  }

  Future<void> _uploadSignature() async {
    final fileService = ref.read(fileServiceProvider);
    final files = await fileService.pickImageFiles();

    if (files.isEmpty) return;

    try {
      final filePath = files.first;
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      if (mounted) {
        Navigator.pop(context, bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image: $e')),
        );
      }
    }
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
