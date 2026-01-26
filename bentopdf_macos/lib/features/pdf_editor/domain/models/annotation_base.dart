import 'package:equatable/equatable.dart';

enum AnnotationType {
  highlight,
  ink,
  signature,
  stamp,
  comment,
  rectangle,
  circle,
  text,
}

abstract class AnnotationBase extends Equatable {
  final String id;
  final AnnotationType type;
  final int pageNumber;
  final DateTime createdAt;

  const AnnotationBase({
    required this.id,
    required this.type,
    required this.pageNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [id, type, pageNumber, createdAt];
}
