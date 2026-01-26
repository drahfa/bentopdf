# Open Source Software Credits

SitiPDF uses the following open-source software packages. We are grateful to their maintainers and contributors.

## Legal Compliance

✅ **Attribution Requirement**: Most packages used in SitiPDF have licenses (MIT, BSD, Apache) that require attribution.

✅ **Implementation**: Open Source Licenses page in Settings → About section displays all package licenses.

✅ **Compliance**: Flutter's built-in `showLicensePage()` automatically gathers and displays all licenses from dependencies.

---

## Core Dependencies

### PDF Processing
- **pdf** (^3.11.0) - Apache-2.0 License
  - PDF document creation and manipulation
  - Repository: https://pub.dev/packages/pdf

- **pdfx** (^2.8.0) - Apache-2.0 License
  - PDF rendering and viewing
  - Repository: https://pub.dev/packages/pdfx

- **printing** (^5.13.0) - Apache-2.0 License
  - PDF printing capabilities
  - Repository: https://pub.dev/packages/printing

### State Management
- **flutter_riverpod** (^2.6.1) - MIT License
  - State management framework
  - Repository: https://pub.dev/packages/flutter_riverpod

- **riverpod_annotation** (^2.6.1) - MIT License
  - Riverpod code generation annotations
  - Repository: https://pub.dev/packages/riverpod_annotation

### Navigation
- **go_router** (^14.6.2) - BSD-3-Clause License
  - Declarative routing for Flutter
  - Repository: https://pub.dev/packages/go_router

### File Operations
- **file_picker** (^8.1.4) - MIT License
  - Native file picker dialogs
  - Repository: https://pub.dev/packages/file_picker

- **desktop_drop** (^0.4.4) - MIT License
  - Drag-and-drop file support
  - Repository: https://pub.dev/packages/desktop_drop

- **path_provider** (^2.1.5) - BSD-3-Clause License
  - System directory paths
  - Repository: https://pub.dev/packages/path_provider

### Internationalization
- **easy_localization** (^3.0.7) - MIT License
  - Localization and translations
  - Repository: https://pub.dev/packages/easy_localization

### Image Processing
- **image** (^4.3.0) - Apache-2.0 License
  - Image manipulation and conversion
  - Repository: https://pub.dev/packages/image

### UI Components
- **reorderables** (^0.6.0) - MIT License
  - Drag-to-reorder UI widgets
  - Repository: https://pub.dev/packages/reorderables

### Utilities
- **equatable** (^2.0.7) - MIT License
  - Value equality helpers
  - Repository: https://pub.dev/packages/equatable

- **dartz** (^0.10.1) - MIT License
  - Functional programming utilities
  - Repository: https://pub.dev/packages/dartz

- **path** (^1.9.0) - BSD-3-Clause License
  - Path manipulation utilities
  - Repository: https://pub.dev/packages/path

---

## Development Dependencies

### Code Quality
- **flutter_lints** (^6.0.0) - BSD-3-Clause License
  - Linting rules for Flutter
  - Repository: https://pub.dev/packages/flutter_lints

### Code Generation
- **build_runner** (^2.4.15) - BSD-3-Clause License
  - Code generation tool
  - Repository: https://pub.dev/packages/build_runner

- **riverpod_generator** (^2.6.3) - MIT License
  - Riverpod code generation
  - Repository: https://pub.dev/packages/riverpod_generator

- **custom_lint** (^0.7.2) - MIT License
  - Custom linting rules
  - Repository: https://pub.dev/packages/custom_lint

- **riverpod_lint** (^2.6.3) - MIT License
  - Riverpod-specific linting
  - Repository: https://pub.dev/packages/riverpod_lint

---

## License Summary

| License Type | Packages Count | Attribution Required |
|--------------|----------------|----------------------|
| MIT | 10+ | ✅ Yes |
| Apache-2.0 | 4 | ✅ Yes |
| BSD-3-Clause | 5 | ✅ Yes |

---

## How Attribution is Provided

### In the App
Users can view all open-source licenses by:
1. Opening SitiPDF
2. Going to Settings
3. Scrolling to About section
4. Clicking "Open Source Licenses"

This displays Flutter's built-in license page with:
- Complete license texts
- Copyright notices
- Package names and versions
- Links to repositories

### In Documentation
This file (OPEN_SOURCE_CREDITS.md) serves as documentation of all dependencies and their licenses.

---

## Compliance Notes

### ✅ We Are Compliant Because:
1. **Attribution Display**: "Open Source Licenses" page in Settings
2. **Complete License Texts**: Flutter automatically includes full license texts
3. **Copyright Notices**: All copyright holders are properly credited
4. **Public Documentation**: This file documents all dependencies

### ⚠️ Important Reminders:
- Update this file when adding/removing dependencies
- Test that license page displays correctly in each release
- Keep package versions updated for security
- Review new package licenses before adding dependencies

---

## Adding New Dependencies

When adding a new open-source package:

1. **Check the License**
   - Visit the package on pub.dev
   - Review the LICENSE file
   - Ensure it's compatible with commercial use

2. **Update This File**
   - Add package to appropriate section
   - Note the license type
   - Add repository link

3. **Verify Attribution**
   - Test that package appears in "Open Source Licenses" page
   - Confirm license text is displayed correctly

4. **Compatible Licenses** (OK to use):
   - ✅ MIT
   - ✅ BSD (2-Clause, 3-Clause)
   - ✅ Apache-2.0
   - ✅ ISC
   - ✅ Creative Commons (for assets)

5. **Incompatible Licenses** (avoid):
   - ❌ GPL (requires releasing source code)
   - ❌ AGPL (requires releasing source code)
   - ❌ Proprietary licenses requiring payment

---

## Frequently Asked Questions

### Do I need to include license files in my distribution?
**Yes**, but Flutter handles this automatically. The `showLicensePage()` function collects all licenses from package `pubspec.yaml` files.

### Can I use these packages in a commercial app?
**Yes**, all listed packages have licenses (MIT, Apache, BSD) that permit commercial use with proper attribution.

### What if I remove a package?
The package will automatically disappear from the "Open Source Licenses" page. Update this documentation file as well.

### Do I need to pay for these packages?
**No**, all packages are free to use. Some licenses require attribution (which we provide), but no payment is required.

### What about Flutter SDK itself?
Flutter is BSD-3-Clause licensed. The license is automatically included when using Flutter apps.

---

## Contact & Updates

**Last Updated**: 2026-01-26
**SitiPDF Version**: 1.3.0
**Maintained By**: VSG Labs

For questions about license compliance, contact: ahmadfaisal9@yahoo.com

---

## Acknowledgments

We extend our gratitude to:
- The Flutter team at Google
- All open-source package maintainers
- The Dart and Flutter communities
- Individual contributors to all packages used

Your work makes SitiPDF possible. Thank you! 🙏
