import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfcow/features/home/presentation/pages/home_page.dart';
import 'package:pdfcow/features/merge_pdf/presentation/pages/merge_pdf_page.dart';
import 'package:pdfcow/features/split_pdf/presentation/pages/split_pdf_page.dart';
import 'package:pdfcow/features/rotate_pdf/presentation/pages/rotate_pdf_page.dart';
import 'package:pdfcow/features/delete_pages/presentation/pages/delete_pages_page.dart';
import 'package:pdfcow/features/extract_pages/presentation/pages/extract_pages_page.dart';
import 'package:pdfcow/features/organize_pdf/presentation/pages/organize_pdf_page.dart';
import 'package:pdfcow/features/encrypt_pdf/presentation/pages/encrypt_pdf_page.dart';
import 'package:pdfcow/features/decrypt_pdf/presentation/pages/decrypt_pdf_page.dart';
import 'package:pdfcow/features/pdf_to_images/presentation/pages/pdf_to_images_page.dart';
import 'package:pdfcow/features/images_to_pdf/presentation/pages/images_to_pdf_page.dart';
import 'package:pdfcow/features/pdf_editor/presentation/pages/pdf_editor_page.dart';
import 'package:pdfcow/features/settings/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/merge-pdf',
      name: 'merge-pdf',
      builder: (context, state) => const MergePdfPage(),
    ),
    GoRoute(
      path: '/split-pdf',
      name: 'split-pdf',
      builder: (context, state) => const SplitPdfPage(),
    ),
    GoRoute(
      path: '/rotate-pdf',
      name: 'rotate-pdf',
      builder: (context, state) => const RotatePdfPage(),
    ),
    GoRoute(
      path: '/delete-pages',
      name: 'delete-pages',
      builder: (context, state) => const DeletePagesPage(),
    ),
    GoRoute(
      path: '/extract-pages',
      name: 'extract-pages',
      builder: (context, state) => const ExtractPagesPage(),
    ),
    GoRoute(
      path: '/organize-pdf',
      name: 'organize-pdf',
      builder: (context, state) => const OrganizePdfPage(),
    ),
    GoRoute(
      path: '/encrypt-pdf',
      name: 'encrypt-pdf',
      builder: (context, state) => const EncryptPdfPage(),
    ),
    GoRoute(
      path: '/decrypt-pdf',
      name: 'decrypt-pdf',
      builder: (context, state) => const DecryptPdfPage(),
    ),
    GoRoute(
      path: '/pdf-to-images',
      name: 'pdf-to-images',
      builder: (context, state) => const PdfToImagesPage(),
    ),
    GoRoute(
      path: '/images-to-pdf',
      name: 'images-to-pdf',
      builder: (context, state) => const ImagesToPdfPage(),
    ),
    GoRoute(
      path: '/pdf-editor',
      name: 'pdf-editor',
      builder: (context, state) => const PdfEditorPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);
