import 'package:flutter/material.dart';
import 'annotation_base.dart';

class InkAnnotation extends AnnotationBase {
  final List<Offset> points;
  final Color color;
  final double thickness;
  final double opacity;

  const InkAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.points,
    required this.color,
    this.thickness = 2.0,
    this.opacity = 1.0,
  }) : super(type: AnnotationType.ink);

  factory InkAnnotation.fromJson(Map<String, dynamic> json) {
    final pointsList = json['points'] as List;
    return InkAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      points: pointsList
          .map((p) => Offset(p['dx'] as double, p['dy'] as double))
          .toList(),
      color: Color(json['color'] as int),
      thickness: json['thickness'] as double? ?? 2.0,
      opacity: json['opacity'] as double? ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'color': color.value,
      'thickness': thickness,
      'opacity': opacity,
    };
  }

  @override
  List<Object?> get props =>
      [...super.props, points, color, thickness, opacity];
}
