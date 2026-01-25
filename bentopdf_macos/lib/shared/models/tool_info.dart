import 'package:flutter/material.dart';

class ToolInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String route;
  final bool isAvailable;

  const ToolInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    this.isAvailable = true,
  });
}

class ToolsConfig {
  static const tools = [
    ToolInfo(
      id: 'merge-pdf',
      name: 'Merge PDF',
      description: 'Combine multiple PDFs into one',
      icon: Icons.merge,
      route: '/merge-pdf',
    ),
    ToolInfo(
      id: 'split-pdf',
      name: 'Split PDF',
      description: 'Extract page ranges',
      icon: Icons.call_split,
      route: '/split-pdf',
    ),
    ToolInfo(
      id: 'rotate-pdf',
      name: 'Rotate PDF',
      description: 'Rotate pages 90 degrees',
      icon: Icons.rotate_90_degrees_cw,
      route: '/rotate-pdf',
    ),
    ToolInfo(
      id: 'extract-pages',
      name: 'Extract Pages',
      description: 'Save specific pages',
      icon: Icons.filter,
      route: '/extract-pages',
    ),
    ToolInfo(
      id: 'delete-pages',
      name: 'Delete Pages',
      description: 'Remove unwanted pages',
      icon: Icons.delete_outline,
      route: '/delete-pages',
    ),
    ToolInfo(
      id: 'organize-pdf',
      name: 'Organize PDF',
      description: 'Drag-drop reorder/duplicate',
      icon: Icons.reorder,
      route: '/organize-pdf',
    ),
    ToolInfo(
      id: 'pdf-to-images',
      name: 'PDF to Images',
      description: 'Export as JPG/PNG',
      icon: Icons.image,
      route: '/pdf-to-images',
    ),
    ToolInfo(
      id: 'images-to-pdf',
      name: 'Images to PDF',
      description: 'Create PDF from images',
      icon: Icons.photo_library,
      route: '/images-to-pdf',
    ),
    ToolInfo(
      id: 'encrypt-pdf',
      name: 'Encrypt PDF',
      description: 'Password protection',
      icon: Icons.lock,
      route: '/encrypt-pdf',
    ),
    ToolInfo(
      id: 'decrypt-pdf',
      name: 'Decrypt PDF',
      description: 'Remove password',
      icon: Icons.lock_open,
      route: '/decrypt-pdf',
    ),
  ];
}
