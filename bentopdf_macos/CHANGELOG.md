# Changelog

All notable changes to the SitiPDF macOS PDF Editor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2026-01-26

### Added

#### PDF Editor Enhancements
- **Page Orientation Detection** - Automatic detection of document orientation
  - Detects portrait, landscape, and square page orientations
  - Reads PDF rotation metadata (0°, 90°, 180°, 270°) from document structure
  - Sandbox-safe PDF parsing without external commands
  - Correctly renders rotated pages with proper aspect ratios
  - Mixed orientation detection for documents with varying page orientations
  - Visual indicator in footer showing current page orientation
  - Rotation angle badge (e.g., "270°") for rotated pages
  - "Mixed" badge for documents containing multiple orientations
  - Swaps width/height dimensions for 90° and 270° rotations
  - Display dimensions account for rotation for accurate rendering

#### Branding & Design
- **Updated App Icons** - New AppIcons_R3 icon set across all platforms
  - macOS: All icon sizes (16px to 1024px) updated
  - Android: All mipmap densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) updated
  - Web: Updated 192px, 512px icons and favicon
  - Top bar icon updated to match new app icon design

- **New Hero Character** - Updated main page branding
  - SitiPDF character mascot with pink hijab holding PDF document
  - Transparent background for clean presentation
  - "SitiPDF Editor" branding integrated into character design
  - Displayed in center hero section of home page (120x120)

#### Settings & Legal
- **Open Source Licenses Page** - Legal compliance for dependencies
  - Clickable "Open Source Licenses" button in About section
  - Uses Flutter's built-in `showLicensePage()` for automatic license collection
  - Displays all third-party software credits and licenses
  - Created comprehensive OPEN_SOURCE_CREDITS.md documentation
  - Covers 15+ dependencies including pdf, pdfx, flutter_riverpod, go_router
  - License types: MIT, Apache-2.0, BSD-3-Clause

### Changed

#### Tool Visibility
- **Temporarily Hidden Tools** - Encrypt and Decrypt PDF tools
  - Encrypt PDF tool commented out in tool list
  - Decrypt PDF tool commented out in tool list
  - Features preserved in codebase for future re-enablement
  - Simplified main tool selection for current release

### Fixed

#### PDF Rendering
- **Landscape PDF Display** - Fixed aspect ratio for rotated documents
  - Correctly handles PDFs with rotation metadata
  - Fixed 270° rotated pages displaying with wrong aspect ratio
  - Render dimensions now swap for 90° and 270° rotations
  - Display width and height account for page rotation
  - Example: 1191x1684 portrait page with 270° rotation displays as 1684x1191 landscape

### Technical

#### New Services
- **PdfMetadataService** - PDF metadata extraction
  - Reads `/Rotate` key directly from PDF structure
  - No external command dependencies (sandbox-safe)
  - Returns rotation in degrees (0, 90, 180, 270)
  - Works with encrypted and password-protected PDFs

#### Enhanced Models
- **PageOrientationInfo** - Comprehensive orientation tracking
  - Stores page number, orientation type, dimensions, and rotation
  - `detectOrientation()` method accounts for rotation metadata
  - `displayWidth` and `displayHeight` getters for rotated dimensions
  - Supports portrait, landscape, and square classifications

#### State Management Updates
- **PdfEditorState** - Added orientation tracking
  - `pageOrientations` list for all page orientation data
  - `hasMixedOrientations` boolean flag
  - Updated `copyWith()` method with new fields

## [1.3.0] - 2026-01-26

### Added

#### Multi-Platform Support
- **Web Platform Support** - Added Flutter web platform
  - Progressive Web App (PWA) capabilities
  - pdf.js integration for PDF rendering on web
  - Responsive design for browser environments
  - Updated app branding to SitiPDF across all web assets

- **Android Platform Support** - Full Android compatibility
  - Android SDK 36 support
  - Native Android APK builds
  - Tested on Pixel 7 Pro emulator
  - File picker integration for Android

#### Settings Updates
- **Publisher Information** - Added "Published by VSG Labs" field
  - Displayed in About section with business icon
  - Professional branding presentation

### Changed
- **App Identity** - Updated branding from pdfcow to SitiPDF
  - Web manifest updated with SitiPDF name
  - Web page title updated across platform
  - Improved app description for web platform

### Fixed
- **PDF Editor Background** - Removed missing background image reference
  - Eliminated 404 errors on web platform
  - Cleaner gradient-only background
  - Better performance across platforms

### Technical
- Platform support: macOS (primary), Web (new), Android (new)
- Web bundle size optimization
- Cross-platform file handling compatibility
- Responsive UI for multiple screen sizes

## [1.2.0] - 2026-01-26

### Added

#### Settings Enhancements
- **Language Selection** - Full language picker with 10 supported languages
  - English, German (Deutsch), Spanish (Español)
  - French (Français), Italian (Italiano), Portuguese (Português)
  - Turkish (Türkçe), Vietnamese (Tiếng Việt)
  - Chinese Simplified (中文), Chinese Traditional (繁體中文)
  - Interactive dropdown with language names in native scripts
  - Persistent language selection using easy_localization

- **Theme Selection** - Light and Dark theme options
  - Interactive theme selector with visual feedback
  - Light Theme option (coming soon)
  - Dark Theme with glassmorphism (current default)
  - State management with Riverpod

#### Delete Pages Feature Enhancement
- **Preview Before Save Workflow** - Improved deletion flow
  - Step 1: Select pages to delete
  - Step 2: Click "Delete Pages" button
  - Step 3: Preview remaining pages before finalizing
  - Step 4: Save or cancel the operation
  - "Cancel" button to return to full page list
  - "Save PDF" button to finalize deletion

#### PDF Editor Enhancements
- **Copy-Paste Annotations** - Duplicate annotations across pages
  - Keyboard shortcuts: Cmd+C/Ctrl+C to copy, Cmd+V/Ctrl+V to paste
  - UI buttons in inspector sidebar for copy and paste
  - 20px offset for pasted annotations to avoid overlap
  - Works with all annotation types

- **Page Manipulation in PDF Editor** - Advanced page operations
  - Delete individual pages with confirmation dialog
  - Duplicate pages within the document
  - Drag-to-reorder pages in sidebar
  - Rotate individual pages (90° clockwise) with button
  - Visual feedback and success messages

- **Drawing Tool Controls** - Enhanced drawing customization
  - Thickness slider (1-20px) for ink annotations
  - Color picker for drawing tool
  - Controls appear when Draw tool is selected

- **Shape Tool Controls** - Complete shape customization
  - Shape type selector (Rectangle/Circle)
  - Thickness slider for shape outlines
  - Color picker for shapes
  - Dynamic controls based on selected tool

- **Zoom Range Extension** - Better document overview
  - Minimum zoom reduced from 50% to 40%
  - Maximum zoom remains at 300%
  - Updated zoom slider divisions (26 steps)
  - Consistent zoom controls across toolbar and canvas

- **Export Quality Improvement** - Higher resolution output
  - Increased render scale from 3.0× (216 DPI) to 4.0× (288 DPI)
  - 33% improvement in export quality
  - Better preservation of annotation details

#### Organize PDF Enhancements
- **Thumbnail Previews** - Visual page representation
  - Actual PDF page thumbnails instead of placeholder icons
  - Grid layout with 6 columns for better overview
  - Drag handle at top of each card for reordering
  - Insertion indicator (glowing vertical line) during drag

#### Delete Pages Tool Enhancement
- **Thumbnail Previews** - Visual page selection
  - Replaced PDF icon placeholders with actual page thumbnails
  - Rendered at 0.4× scale for optimal performance
  - Maintains 6-column grid layout
  - Visual feedback for selected pages

### Changed

#### Settings Page Improvements
- **License Information** - Updated licensing details
  - Changed from "Open Source" to "Commercial License"
  - Added detailed license description
  - Clear statement: "Proprietary software. All rights reserved."
  - Clarification on unauthorized use restrictions

- **Attribution Updates** - Refined author presentation
  - Author names no longer displayed in bold (changed from w600 to w400)
  - Maintains clear readability with regular font weight
  - Consistent with overall design aesthetic

- **Version Bump** - Updated version information
  - Version displayed as 1.2.0 in Settings page
  - Consistent with pubspec.yaml and app metadata

#### Rotation Quality Fixes
- **Individual Page Rotation** - Fixed multiple rotation issues
  - Fixed aspect ratio distortion by removing BoxFit parameters
  - Fixed content cutoff by adding zero margins
  - Fixed zooming problems by centering rotated content
  - Proper page format swapping for 90°/270° rotations
  - Consistent quality across all rotation angles

#### Drag-and-Drop Improvements
- **Organize PDF Drag Behavior** - Better user experience
  - Changed from LongPressDraggable to regular Draggable
  - Added visible drag handle icon at top of cards
  - Insertion indicator instead of card highlight
  - Clear visual feedback for drop position

### Fixed

#### Layout and UI Issues
- **Inspector Sidebar Width** - Fixed button visibility
  - Increased width from 190px to 240px
  - Now accommodates edit, copy, and delete buttons
  - No more button overflow

- **Pages Sidebar Rendering** - Fixed blank sidebar issue
  - Added `buildDefaultDragHandles: false` to ReorderableListView
  - Fixed height containers and drag listeners
  - Proper ReorderableDragStartListener configuration

- **Button Layout Overflow** - Fixed pixel overflow errors
  - Reduced button sizes from 18×18 to 16×16 pixels
  - Adjusted spacing from 2px to 1px
  - Eliminated RenderFlex overflow warnings

### Technical Details

#### New Components
- **Settings Provider** - New state management for app settings
  - `/lib/features/settings/presentation/providers/settings_provider.dart`
  - AppThemeMode enum (light/dark)
  - SettingsState with theme mode tracking
  - SettingsNotifier for state updates

#### Updated State Management
- **Delete Pages Provider** - Enhanced with preview mode
  - Added `previewMode` boolean to state
  - Added `remainingPages` list for preview
  - Split `deletePages()` into preview and save operations
  - New `cancelPreview()` method to revert changes

#### UI Components
- **Theme Selector** - Interactive theme switching widget
  - Two-option horizontal selector (Light/Dark)
  - Visual feedback with gradient backgrounds
  - Icon and text labels for each option

- **Language Dropdown** - Multi-language selector
  - DropdownButton with 10 language options
  - Native language names displayed
  - Locale persistence with easy_localization

---

## [1.1.0] - 2026-01-25

### Added

#### UI/UX Modernization
- **Glassmorphism Design System** - Complete UI overhaul with modern glassmorphism aesthetic
  - Dark gradient backgrounds with radial overlays
  - Glass panel components with backdrop blur effects
  - Consistent color scheme across all modules
  - 18px border radius for rounded corners throughout
  - Professional glass styling with borders and shadows

- **Modernized Home Page** - Complete redesign of main menu
  - Glass panel topbar with PDFcow branding and settings button
  - Hero section with large heading and tagline
  - Responsive tool card grid (230px min width, 2-6 columns)
  - Hover effects on tool cards (translateY, border glow, enhanced shadows)
  - Radial gradient background overlays
  - PDF Editor moved to first position in tool list

- **Settings Page** - New dedicated settings interface
  - Appearance section with theme information
  - Language section showing current locale
  - About section with version and license info
  - Attribution section: "Made with ❤️ by Ahmad Faisal Mohamad Ayob, VSG Labs, Universiti Malaysia Terengganu"
  - Back button navigation to home page

- **Standardized PDF Tool Pages** - All 11 PDF tools updated with glassmorphism
  - Merge PDF - Glass-styled file list and drop zone
  - Split PDF - Glass panel with page range inputs
  - Rotate PDF - Glass cards with rotation angle chips
  - Extract Pages - Glassmorphism page range selector
  - Delete Pages - Glass-styled page deletion interface
  - Organize PDF - Reorderable glass panel items
  - PDF to Images - Glass format selection cards
  - Images to PDF - Glass-styled image list
  - Encrypt PDF - Glass panel password inputs
  - Decrypt PDF - Glass-styled unlock interface
  - PDF Editor - Already had glassmorphism (unchanged)

#### Window Management
- **Maximized by Default** - App now launches maximized (not fullscreen)
  - Uses screen's visible frame for optimal window size
  - Maintains window controls (minimize, maximize, close)
  - Better initial user experience on launch

### Changed

#### Design Consistency
- **Unified Header Design** - All tool pages now have consistent headers
  - Back button (← icon) to return to home
  - Icon container with tool-specific icon and accent color background
  - Tool name/title display
  - Action buttons aligned to the right

- **Glass Panel Components** - Standardized across all pages
  - Error banners with danger color and glass styling
  - Success banners with accent2 (green) color and glass styling
  - Drop zones with glass panels and icon containers
  - File/page list items with glass gradient backgrounds
  - Bottom action bars with glass panel styling

- **Button Styling** - Consistent button design system
  - Primary buttons use PdfEditorTheme.buttonDecoration(isPrimary: true)
  - Secondary buttons with glass styling and borders
  - Ghost buttons with transparent backgrounds
  - Disabled state styling for inactive buttons

- **Color Usage** - Systematic application of theme colors
  - PdfEditorTheme.accent (#7c5cff) - Primary actions and highlights
  - PdfEditorTheme.accent2 (#22c55e) - Success states and good actions
  - PdfEditorTheme.danger (#ef4444) - Errors and destructive actions
  - PdfEditorTheme.warn (#f59e0b) - Warnings
  - PdfEditorTheme.text (#e8ecff) - Primary text
  - PdfEditorTheme.muted (#a7b2de) - Secondary text

### Technical Details

#### New Components
- **Settings Feature** - New feature module added
  - `/lib/features/settings/presentation/pages/settings_page.dart`
  - Settings route added to app router (`/settings`)
  - Integrated with go_router navigation

#### Updated Routes
- Added `/settings` route for settings page
- All tool pages now use go_router for back button navigation
  - `context.go('/')` for consistent navigation behavior

#### Theme System
- PdfEditorTheme reused across all modules for consistency
- Glass panel widget utilized throughout the app
- Standardized spacing, padding, and margin values

---

## [1.0.0] - 2026-01-24

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
