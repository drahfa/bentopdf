import 'package:flutter/material.dart';
import 'annotation_base.dart';

class CommentAnnotation extends AnnotationBase {
  final String text;
  final Offset position;
  final Color color;

  const CommentAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.text,
    required this.position,
    this.color = Colors.yellow,
  }) : super(type: AnnotationType.comment);

  factory CommentAnnotation.fromJson(Map<String, dynamic> json) {
    return CommentAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String,
      position: Offset(
        json['position']['dx'] as double,
        json['position']['dy'] as double,
      ),
      color: Color(json['color'] as int),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'text': text,
      'position': {'dx': position.dx, 'dy': position.dy},
      'color': color.value,
    };
  }

  @override
  List<Object?> get props => [...super.props, text, position, color];
}
