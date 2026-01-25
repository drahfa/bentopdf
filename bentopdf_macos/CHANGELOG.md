# Changelog

All notable changes to the PDFcow macOS PDF Editor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Core PDF Editor Features
- **PDF Annotation System** - Full-featured PDF annotation and editing capabilities
  - Highlight annotations with color picker and opacity control
  - Freehand drawing/ink annotations with adjustable thickness (1-20px)
  - Shape annotations (rectangles and circles)
  - Stamp/image annotations with upload support
  - Signature annotations (draw or upload)
  - Annotation selection, drag, resize, and delete
  - Real-time annotation preview while drawing
  - All annotation types (stamps, signatures, highlights, shapes, ink) are selectable, movable, and deletable

#### Annotation Interaction
- **Resize Handles (Gizmos)** - Visual handles for manipulating annotations
  - Corner handles for resizing annotations (20px, increased from 12px for better grabability)
  - Center drag handle with gradient styling for easy movement
  - Handles consume tap events to prevent accidental deselection
  - 200ms protection window after drag operations to prevent gizmo disappearing

- **Keyboard Navigation** - Precise annotation control with keyboard
  - Arrow keys: Move selected annotation 1px per press
  - Shift + Arrow keys: Move 10px per press for faster positioning
  - Delete/Backspace: Remove selected annotation

- **Intelligent Mode Switching** - Automatic tool mode changes for better UX
  - Clicking on annotation → Switches to Select mode
  - Clicking on empty space → Switches to Pan mode
  - Maintains proper gesture handling in both modes

#### UI/UX Enhancements
- **Dark Glassmorphism Theme** - Modern dark blue/purple UI with glass effects
  - Custom color scheme: dark blue background (#0b1020), purple accent (#7c5cff), green accent (#22c55e)
  - Glassmorphism panels with backdrop blur effects
  - Smooth shadows, rounded corners (18px), and gradient backgrounds
  - Professional glass panel widgets with border and shadow effects

- **Improved Layout System**
  - Grid-based layout with dedicated panels
  - Header with "PDF Editor" branding and action buttons
  - Left sidebar: Page thumbnails in single-column layout (160px width)
  - Main canvas area with annotation toolbar
  - Right sidebar: Inspector panel showing document info and annotations (190px width)
  - Footer with status indicator and file information
  - Bottom controls bar for page navigation and zoom

- **Interactive Inspector Sidebar** - Click to manage annotations
  - Click annotation item to select it on canvas (gizmo appears)
  - Delete button on each layer item for quick removal
  - Visual feedback for selected annotations
  - Live sync with canvas selection state

- **Live Page Thumbnails** - Real-time preview in sidebar
  - Thumbnails render actual PDF pages with all annotations
  - Auto-updates when annotations are added, moved, or deleted
  - White background for proper page display
  - Loading indicators during thumbnail generation
  - Highlights currently active page

- **Navigation Tools**
  - Pan tool for canvas navigation (default mode)
  - Select tool for annotation interaction
  - Mouse wheel/trackpad scrolling support in X and Y directions
  - Interactive zoom with pinch/scroll gestures
  - Zoom controls (50%-300%) with slider, +/- buttons, and percentage display
  - Page navigation controls (previous/next page)

- **Responsive Toolbar**
  - Dynamic toolbar that wraps to two rows when horizontal space is limited
  - Tools: Pan, Select, Highlight, Draw, Shape, Stamp, Signature
  - Delete button appears when annotation is selected
  - Modern tool button styling with active states

#### Window Management
- Minimum window size set to 1000×600 pixels (increased from 800px for better usability)
- Default zoom level set to 50% for better initial view
- Optimized sidebar design: Pages sidebar 160px, Inspector sidebar 190px

#### Export & Persistence
- Export annotated PDFs with all annotations rendered
- Maintain aspect ratios for stamps and signatures
- Correct coordinate mapping between canvas and PDF output
- Progress indicator during export
- Image caching for efficient rendering

### Fixed

#### Annotation Issues
- **Stamp Visibility** - Fixed stamps disappearing after placement by implementing image cache
- **Drag/Resize Gizmo** - Fixed gizmo disappearing during drag by using temporary bounds
- **Position Accuracy** - Fixed position and size mismatch in exported PDFs by adjusting scale
- **Aspect Ratio** - Fixed PDF document stretching by unconstrained InteractiveViewer
- **Stamp Aspect Ratio** - Fixed stamp image distortion by decoding and calculating proper bounds
- **Export Quality** - Fixed stamps not appearing in exported PDFs by passing image cache to export service
- **Gizmo Click Detection** - Fixed gizmo disappearing when clicked by adding tap event handlers and expanded bounds checking
- **Post-Drag Deselection** - Fixed annotations deselecting immediately after drag with 200ms protection window
- **Transparent Stamp Selection** - Fixed difficulty selecting stamps with transparent backgrounds by adding center drag handle
- **Pan Mode Scrolling** - Fixed document not scrolling in pan mode by conditionally enabling gesture handlers
- **Annotation Movement** - Fixed inability to move highlights, shapes, and ink annotations by implementing drag support for all types

#### Layout Issues
- Prevented aspect ratio distortion with `constrained: false` on InteractiveViewer
- Fixed coordinate system mapping (2x scaled view coordinates)
- Proper bounds calculation for resizable annotations

### Changed

#### UI Improvements
- Reduced pages sidebar width from 320px to 160px (50% reduction)
- Updated inspector sidebar width to 190px for better content display
- Changed page thumbnails from 2-column to 1-column layout
- Moved page navigation and zoom controls from top toolbar to bottom bar
- Default tool changed from "Select" to "Pan" for better initial UX
- Changed Select tool icon from pan_tool to touch_app for clarity
- Updated header branding from "PDFcow Editor" to "PDF Editor"
- Increased resize handle size from 12px to 20px for better usability
- Added gradient-styled center drag handle (32px) for easier annotation movement
- Added white background to page thumbnails for proper display
- Increased minimum window width from 800px to 1000px

#### Technical Improvements
- Implemented deferred update pattern for smooth drag/resize operations
- Added state management for temporary bounds during transformations
- Optimized rendering with CustomPaint and AnnotationPainter
- Image caching system for stamp and signature annotations
- Aspect ratio preservation through image decoding
- Conditional gesture handling to prevent conflicts between pan and annotation modes
- Keyboard event handling with Focus widget for arrow key navigation
- Tap event consumption on gizmo handles to prevent propagation
- Expanded bounds checking for reliable annotation selection (25px buffer)
- Time-based tap filtering (200ms window) after drag operations
- Live thumbnail rendering with FutureBuilder and async page rendering
- All annotation types support bounds updates for drag/resize operations
- Ink annotation point translation for movement while preserving shape

### Technical Details

#### Architecture
- **Clean Architecture Pattern** - Features organized in presentation/domain/data layers
- **State Management** - Riverpod with StateNotifier pattern
- **Custom Canvas Overlay** - Flutter CustomPaint over pdfx PDF viewer
- **Export Pipeline** - Canvas → Image → PDF composite rendering

#### Dependencies
- `pdfx: ^2.9.2` - PDF rendering and viewing
- `pdf: ^3.11.0` - PDF creation and export
- `image: ^4.5.4` - Image manipulation for annotations
- `flutter_riverpod: ^2.6.1` - State management
- `file_picker: ^8.3.7` - File selection dialogs

#### File Structure
```
lib/features/pdf_editor/
├── domain/models/           # Annotation models (base, highlight, ink, shape, signature, stamp, comment)
├── data/painters/           # CustomPainter for annotation rendering
├── presentation/
│   ├── pages/              # PDF Editor main page
│   ├── providers/          # Riverpod state management
│   └── widgets/            # UI components (header, toolbar, sidebars, canvas, controls)
lib/shared/
├── services/               # Annotation, export, and file services
└── widgets/                # Reusable components (glass panel)
lib/core/
└── theme/                  # PDF Editor theme and styling
```

### Known Limitations
- Annotations are rasterized during export (not true PDF vector annotations)
- Export time increases with document size and annotation count
- Quality depends on render scale (currently 2x)

---

## Future Considerations

### Potential Enhancements
- Text annotations with custom fonts and sizes
- Comment sidebar with threaded discussions
- Undo/redo functionality for annotations
- Annotation layers and grouping
- Keyboard shortcuts for tools
- Export to other formats (images, etc.)
- Cloud storage integration
- Collaborative editing features

### Performance Optimizations
- Lazy loading for page thumbnails
- Progressive export with better progress tracking
- Background processing for large documents
- More aggressive annotation caching

---

**Note**: This changelog documents the initial implementation of the PDF Editor feature for PDFcow macOS. All features are functional and tested on macOS.
