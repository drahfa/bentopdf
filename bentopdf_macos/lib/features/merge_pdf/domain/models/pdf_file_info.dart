import 'package:equatable/equatable.dart';

class PdfFileInfo extends Equatable {
  final String path;
  final String name;
  final int? pageCount;

  const PdfFileInfo({
    required this.path,
    required this.name,
    this.pageCount,
  });

  PdfFileInfo copyWith({
    String? path,
    String? name,
    int? pageCount,
  }) {
    return PdfFileInfo(
      path: path ?? this.path,
      name: name ?? this.name,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  @override
  List<Object?> get props => [path, name, pageCount];
}
