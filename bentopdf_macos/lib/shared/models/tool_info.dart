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
      id: 'pdf_editor',
      name: 'tools.pdf_editor.name',
      description: 'tools.pdf_editor.description',
      icon: Icons.edit,
      route: '/pdf-editor',
    ),
    ToolInfo(
      id: 'merge_pdf',
      name: 'tools.merge_pdf.name',
      description: 'tools.merge_pdf.description',
      icon: Icons.merge,
      route: '/merge-pdf',
    ),
    ToolInfo(
      id: 'split_pdf',
      name: 'tools.split_pdf.name',
      description: 'tools.split_pdf.description',
      icon: Icons.call_split,
      route: '/split-pdf',
    ),
    ToolInfo(
      id: 'rotate_pdf',
      name: 'tools.rotate_pdf.name',
      description: 'tools.rotate_pdf.description',
      icon: Icons.rotate_90_degrees_cw,
      route: '/rotate-pdf',
    ),
    ToolInfo(
      id: 'extract_pages',
      name: 'tools.extract_pages.name',
      description: 'tools.extract_pages.description',
      icon: Icons.filter,
      route: '/extract-pages',
    ),
    ToolInfo(
      id: 'delete_pages',
      name: 'tools.delete_pages.name',
      description: 'tools.delete_pages.description',
      icon: Icons.delete_outline,
      route: '/delete-pages',
    ),
    ToolInfo(
      id: 'organize_pdf',
      name: 'tools.organize_pdf.name',
      description: 'tools.organize_pdf.description',
      icon: Icons.reorder,
      route: '/organize-pdf',
    ),
    ToolInfo(
      id: 'pdf_to_images',
      name: 'tools.pdf_to_images.name',
      description: 'tools.pdf_to_images.description',
      icon: Icons.image,
      route: '/pdf-to-images',
    ),
    ToolInfo(
      id: 'images_to_pdf',
      name: 'tools.images_to_pdf.name',
      description: 'tools.images_to_pdf.description',
      icon: Icons.photo_library,
      route: '/images-to-pdf',
    ),
    // Temporarily hidden - Encrypt/Decrypt PDF
    /* ToolInfo(
      id: 'encrypt_pdf',
      name: 'tools.encrypt_pdf.name',
      description: 'tools.encrypt_pdf.description',
      icon: Icons.lock,
      route: '/encrypt-pdf',
    ),
    ToolInfo(
      id: 'decrypt_pdf',
      name: 'tools.decrypt_pdf.name',
      description: 'tools.decrypt_pdf.description',
      icon: Icons.lock_open,
      route: '/decrypt-pdf',
    ), */
  ];
}
