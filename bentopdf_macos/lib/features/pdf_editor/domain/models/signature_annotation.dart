import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'annotation_base.dart';

class SignatureAnnotation extends AnnotationBase {
  final Uint8List imageData;
  final Rect bounds;

  const SignatureAnnotation({
    required super.id,
    required super.pageNumber,
    required super.createdAt,
    required this.imageData,
    required this.bounds,
  }) : super(type: AnnotationType.signature);

  factory SignatureAnnotation.fromJson(Map<String, dynamic> json) {
    return SignatureAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageData: Uint8List.fromList((json['imageData'] as List).cast<int>()),
      bounds: Rect.fromLTRB(
        json['bounds']['left'] as double,
        json['bounds']['top'] as double,
        json['bounds']['right'] as double,
        json['bounds']['bottom'] as double,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'imageData': imageData.toList(),
      'bounds': {
        'left': bounds.left,
        'top': bounds.top,
        'right': bounds.right,
        'bottom': bounds.bottom,
      },
    };
  }

  @override
  List<Object?> get props => [...super.props, imageData, bounds];
}
