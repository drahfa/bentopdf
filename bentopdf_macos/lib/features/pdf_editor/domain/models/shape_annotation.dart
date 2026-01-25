import 'package:flutter/material.dart';
import 'annotation_base.dart';

enum ShapeType { rectangle, circle }

class ShapeAnnotation extends AnnotationBase {
  final ShapeType shapeType;
  final Rect bounds;
  final Color color;
  final double strokeWidth;
  final double opacity;
  final bool filled;

  const ShapeAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.shapeType,
    required this.bounds,
    required this.color,
    this.strokeWidth = 2.0,
    this.opacity = 0.5,
    this.filled = false,
  }) : super(
          type: shapeType == ShapeType.rectangle
              ? AnnotationType.rectangle
              : AnnotationType.circle,
        );

  factory ShapeAnnotation.fromJson(Map<String, dynamic> json) {
    return ShapeAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      shapeType: ShapeType.values.firstWhere(
        (e) => e.name == json['shapeType'],
      ),
      bounds: Rect.fromLTRB(
        json['bounds']['left'] as double,
        json['bounds']['top'] as double,
        json['bounds']['right'] as double,
        json['bounds']['bottom'] as double,
      ),
      color: Color(json['color'] as int),
      strokeWidth: json['strokeWidth'] as double? ?? 2.0,
      opacity: json['opacity'] as double? ?? 0.5,
      filled: json['filled'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'shapeType': shapeType.name,
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
      'color': color.value,
      'strokeWidth': strokeWidth,
      'opacity': opacity,
      'filled': filled,
    };
  }

  @override
  List<Object?> get props => [
        ...super.props,
        shapeType,
        bounds,
        color,
        strokeWidth,
        opacity,
        filled,
      ];
}
