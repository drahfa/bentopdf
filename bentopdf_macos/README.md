# PDFcow - Native macOS PDF Toolkit

A native Flutter macOS application providing 95+ PDF manipulation tools with significantly reduced memory footprint compared to WebView-based implementations.

## Project Status

**Current Phase**: Phase 1 Complete! 🎉

### Completed

#### Phase 1 - Infrastructure (Week 1-2)
- ✅ Flutter project initialization
- ✅ Feature-first clean architecture setup
- ✅ Riverpod state management configuration
- ✅ go_router navigation setup
- ✅ Material Design 3 dark theme (macOS-adapted)
- ✅ Home page: "Your Friendly PDF Editor"
- ✅ Basic PDF service infrastructure
- ✅ File picker service
- ✅ All tests passing

#### Sprint 2 - Basic Tools (Week 3-4)
- ✅ Merge PDF - Multi-file selection, drag-drop, reordering
- ✅ Split PDF - Page range extraction with validation
- ✅ Rotate PDF - 90°, 180°, 270° rotation options
- ✅ Delete Pages - Multi-select grid UI for page deletion
- ✅ PDF manipulation service using pdfx package
- ✅ Error handling and success notifications
- ✅ Loading states for async operations

#### Sprint 3 - Advanced Tools (Week 5-6)
- ✅ Extract Pages - Multi-select grid UI with page extraction
- ✅ Organize PDF - Drag-drop reordering with duplicate/delete
- ✅ Encrypt PDF - Password protection with confirmation
- ✅ Decrypt PDF - Password removal with validation
- ✅ PDF security service for encryption/decryption
- ✅ Reorderable list UI for page organization

#### Sprint 4 - Images & Polish (Week 7-8)
- ✅ PDF to Images - Export to JPG/PNG with quality control
- ✅ Images to PDF - Multi-image import with reordering
- ✅ Image conversion service with format selection
- ✅ Quality slider for JPG compression
- ✅ Drag-drop support for images
- ✅ All 10 Phase 1 tools fully implemented!

### Directory Structure
```
lib/
├── core/
│   ├── di/               # Riverpod providers (5 services)
│   ├── router/           # go_router navigation (10 routes)
│   └── theme/            # Material theme (dark mode)
├── features/             # 10 fully implemented tools
│   ├── home/             # ✅ "Your Friendly PDF Editor"
│   ├── merge_pdf/        # ✅ Implemented
│   ├── split_pdf/        # ✅ Implemented
│   ├── rotate_pdf/       # ✅ Implemented
│   ├── delete_pages/     # ✅ Implemented
│   ├── extract_pages/    # ✅ Implemented
│   ├── organize_pdf/     # ✅ Implemented
│   ├── encrypt_pdf/      # ✅ Implemented
│   ├── decrypt_pdf/      # ✅ Implemented
│   ├── pdf_to_images/    # ✅ Implemented
│   └── images_to_pdf/    # ✅ Implemented
│       └── presentation/
│           ├── pages/
│           ├── widgets/
│           └── providers/
└── shared/
    ├── models/           # ToolInfo, PdfFileInfo, PageItem, ImageInfo
    ├── services/         # PdfService, FileService, PdfManipulationService,
    │                     # PdfSecurityService, ImageConversionService
    └── widgets/
```

### All 10 Phase 1 Tools Complete! ✅
1. ✅ **Merge PDF** - Combine multiple PDFs with drag-drop and reordering
2. ✅ **Split PDF** - Extract page ranges with validation
3. ✅ **Rotate PDF** - Rotate all pages by 90°, 180°, or 270°
4. ✅ **Delete Pages** - Remove unwanted pages with multi-select grid UI
5. ✅ **Extract Pages** - Save specific pages with multi-select grid UI
6. ✅ **Organize PDF** - Drag-drop reorder, duplicate, and delete pages
7. ✅ **Encrypt PDF** - Password protection with confirmation
8. ✅ **Decrypt PDF** - Remove password with validation
9. ✅ **PDF to Images** - Export to JPG/PNG with quality control
10. ✅ **Images to PDF** - Create PDF from multiple images with reordering

### Key Dependencies
- `flutter_riverpod` ^2.6.1 - State management
- `go_router` ^14.6.2 - Navigation
- `pdf` ^3.11.0 - PDF creation
- `pdfx` ^2.9.2 - PDF manipulation & rendering
- `printing` ^5.14.2 - PDF preview
- `file_picker` ^8.3.7 - File/folder selection
- `desktop_drop` ^0.4.4 - Drag-drop support
- `reorderables` ^0.6.0 - List reordering
- `path_provider` ^2.1.5 - System paths
- `image` ^4.5.4 - Image processing & conversion
- `equatable` ^2.0.7 - Value equality
- `dartz` ^0.10.1 - Functional programming

## Getting Started

### Prerequisites
- Flutter 3.38.6 or higher
- macOS development environment
- Xcode

### Running the App
```bash
flutter pub get
flutter run -d macos
```

### Building
```bash
flutter build macos --release
```

### Testing
```bash
flutter test
flutter analyze
```

## Phase 1 Complete! 🎉

All 10 core PDF tools have been successfully implemented with:
- ✅ Native macOS performance
- ✅ Clean, intuitive UI
- ✅ Drag-drop support
- ✅ Multi-select capabilities
- ✅ Error handling & validation
- ✅ Success notifications
- ✅ No uploads required (100% local)

### App Statistics
- **33 Dart files** created
- **10 fully functional tools**
- **5 core services** (PDF, File, Manipulation, Security, Image Conversion)
- **10 navigation routes**
- **Zero analysis issues**
- **All tests passing**

## Next Steps - Phase 2 Enhancements

### Polish & Quality (Weeks 9-10)
- [ ] Set up i18n (11 languages from web version)
- [ ] Add unit tests for all services
- [ ] Add widget tests for all features
- [ ] Achieve 70% test coverage
- [ ] Performance optimization for large PDFs (100+ pages)
- [ ] Memory profiling and optimization

### User Experience (Weeks 11-12)
- [ ] PDF thumbnail previews in file lists
- [ ] Progress indicators for large files
- [ ] Better error messages with actionable suggestions
- [ ] Keyboard shortcuts (Cmd+O, Cmd+S, etc.)
- [ ] Native macOS menu bar integration
- [ ] Recent files list
- [ ] Settings page (theme, default quality, etc.)

### Advanced Features (Phase 2+)
- [ ] Batch processing support
- [ ] PDF compression (PyMuPDF integration)
- [ ] OCR support (Google ML Kit)
- [ ] Watermark tool
- [ ] Page numbers tool
- [ ] Header & footer tool
- [ ] PDF metadata editor

## Memory Goal
Target: 30-80MB runtime memory usage (vs 150-300MB for WebView-based implementation)

## License
Same as parent project
