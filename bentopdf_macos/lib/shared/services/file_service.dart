import 'package:file_picker/file_picker.dart';

class FileService {
  Future<String?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    return result?.files.single.path;
  }

  Future<List<String>> pickMultiplePdfFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    return result?.files.map((file) => file.path!).toList() ?? [];
  }

  Future<List<String>> pickImageFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    return result?.files.map((file) => file.path!).toList() ?? [];
  }

  Future<String?> getSaveLocation({String? suggestedName}) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: suggestedName ?? 'output.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    return result;
  }

  Future<String?> getDirectoryPath() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select folder to save images',
    );

    return result;
  }
}
