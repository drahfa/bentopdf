import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_providers.dart';

class StampDialog extends ConsumerStatefulWidget {
  const StampDialog({super.key});

  @override
  ConsumerState<StampDialog> createState() => _StampDialogState();
}

class _StampDialogState extends ConsumerState<StampDialog> {
  Uint8List? _previewImage;
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 450,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Add Stamp/Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _previewImage != null
                  ? _buildPreview()
                  : _buildUploadPrompt(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_previewImage != null) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _previewImage = null;
                        _fileName = null;
                      });
                    },
                    child: const Text('Change'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: _previewImage != null ? _addStamp : _selectImage,
                  child: Text(_previewImage != null ? 'Add Stamp' : 'Choose File'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Upload an image to use as a stamp',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Supported formats: PNG, JPG, GIF, BMP',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        if (_fileName != null)
          Text(
            _fileName!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
            ),
            child: Center(
              child: Image.memory(
                _previewImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectImage() async {
    final fileService = ref.read(fileServiceProvider);
    final files = await fileService.pickImageFiles();

    if (files.isEmpty) return;

    try {
      final filePath = files.first;
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      setState(() {
        _previewImage = bytes;
        _fileName = filePath.split('/').last;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image: $e')),
        );
      }
    }
  }

  void _addStamp() {
    if (_previewImage != null) {
      Navigator.pop(context, _previewImage);
    }
  }
}
