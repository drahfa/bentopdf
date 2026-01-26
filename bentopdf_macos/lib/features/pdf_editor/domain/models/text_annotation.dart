import 'package:flutter/material.dart';
import 'annotation_base.dart';

class TextAnnotation extends AnnotationBase {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;

  const TextAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.text,
    required this.position,
    this.color = Colors.black,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'Helvetica',
  }) : super(type: AnnotationType.text);

  TextAnnotation copyWith({
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
  }) {
    return TextAnnotation(
      id: id,
      pageNumber: pageNumber,
      createdAt: createdAt,
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  factory TextAnnotation.fromJson(Map<String, dynamic> json) {
    return TextAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String,
      position: Offset(
        json['position']['dx'] as double,
        json['position']['dy'] as double,
      ),
      color: Color(json['color'] as int),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontWeight: FontWeight.values[json['fontWeight'] as int? ?? 3],
      fontFamily: json['fontFamily'] as String? ?? 'Helvetica',
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
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'fontFamily': fontFamily,
    };
  }

  @override
  List<Object?> get props => [...super.props, text, position, color, fontSize, fontWeight, fontFamily];
}
