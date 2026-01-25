import 'package:flutter/material.dart';
import 'annotation_base.dart';

class HighlightAnnotation extends AnnotationBase {
  final Rect bounds;
  final Color color;
  final double opacity;

  const HighlightAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.bounds,
    required this.color,
    this.opacity = 0.3,
  }) : super(type: AnnotationType.highlight);

  factory HighlightAnnotation.fromJson(Map<String, dynamic> json) {
    return HighlightAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      bounds: Rect.fromLTRB(
        json['bounds']['left'] as double,
        json['bounds']['top'] as double,
        json['bounds']['right'] as double,
        json['bounds']['bottom'] as double,
      ),
      color: Color(json['color'] as int),
      opacity: json['opacity'] as double? ?? 0.3,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
      'color': color.value,
      'opacity': opacity,
    };
  }

  @override
  List<Object?> get props => [...super.props, bounds, color, opacity];
}
