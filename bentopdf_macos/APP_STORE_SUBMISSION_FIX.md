# App Store Submission Fix - ITMS-90291

## Issue Received from Apple

```
ITMS-90291: Malformed Framework - The framework bundle objective_c
(SitiPDF.app/Contents/Frameworks/objective_c.framework) must contain
a symbolic link 'Resources' -> 'Versions/Current/Resources'.
```

**App Details:**
- App Name: SitiPDF
- App Apple ID: 6758303516
- Version: 1.4.0
- Build: 5

## Root Cause

The `objective_c` framework (a transitive dependency from Flutter packages, version 9.2.4) was not properly structured according to Apple's framework bundle requirements. Apple requires frameworks to follow the standard macOS framework structure with proper symbolic links:

```
Framework.framework/
├── Resources -> Versions/Current/Resources (symlink)
├── Framework -> Versions/Current/Framework (symlink)
└── Versions/
    ├── A/
    │   ├── Resources/
    │   └── Framework (binary)
    └── Current -> A (symlink)
```

## Solution Implemented

### 1. Updated Version Number
- Updated from **1.4.0+5** to **1.4.1+6**
- Updated Settings page to show 1.4.1
- Updated CHANGELOG.md with v1.4.1 release notes

### 2. Added LSApplicationCategoryType
- Added required key to `macos/Runner/Info.plist`
- Value: `public.app-category.productivity`
- This was also required for App Store validation

### 3. Created Framework Fix Script
- Created `macos/fix_frameworks.sh`
- Script ensures all frameworks have correct symbolic link structure
- Automatically fixes any frameworks missing proper Versions/Current structure

### 4. Automated Xcode Build Phase Addition
- Created `add_build_phase.py` script
- Automatically adds "Fix Framework Structures" run script build phase to Xcode project
- **Already executed** - Build phase is now in your Xcode project
- Phase ID: `231E6C63C630496B93A8D400`

## Verification

Current build structure verified:
```bash
✓ objective_c.framework has correct structure:
  - Resources -> Versions/A/Resources (symlink exists)
  - objective_c -> Versions/Current/objective_c (symlink exists)
  - Versions/Current -> A (symlink exists)
```

## Next Steps for App Store Submission

### Step 1: Clean Build
```bash
flutter clean
flutter pub get
cd macos
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Step 2: Build Release Version
```bash
flutter build macos --release
```

### Step 3: Archive in Xcode
1. Open Xcode workspace:
   ```bash
   open macos/Runner.xcworkspace
   ```

2. Select destination: **Any Mac (Apple Silicon, Intel)**

3. Archive the app:
   - Menu: **Product > Archive**
   - Wait for archive to complete

4. In Organizer window:
   - Your archive will appear
   - Click **Distribute App**

### Step 4: Validate Before Upload
1. Select **App Store Connect**
2. Click **Next** through distribution options
3. Select **Validate App** (not Upload yet)
4. Wait for validation to complete

**Expected result:** Validation should pass without ITMS-90291 error

**Expected warning (safe to ignore):**
```
The archive did not include a dSYM for the A with the UUIDs
[254407D4-ED4A-3260-954F-3F172B707B4C, 6B69F345-906C-3257-BBB7-A9566239BBA6].
```

This warning is about the `objective_c.framework` (third-party pre-built binary) and does not prevent App Store submission. See `DSYM_WARNING_INFO.md` for detailed explanation. You can safely proceed to upload.

### Step 5: Upload to App Store Connect
Once validation passes:
1. Return to Organizer
2. Click **Distribute App** again
3. Select **App Store Connect**
4. Select **Upload**
5. Complete the upload process

### Step 6: Submit for Review in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Navigate to SitiPDF app
3. Select version **1.4.1**
4. Complete all required fields:
   - Screenshots
   - Description (use APP_STORE_DESCRIPTION.md)
   - Keywords
   - Support URL
   - Privacy policy (if required)
5. Select the build (1.4.1 build 6)
6. Click **Submit for Review**

## Files Created/Modified

### New Files:
- `macos/fix_frameworks.sh` - Framework structure fix script
- `add_build_phase.py` - Xcode project automation script
- `APP_STORE_DESCRIPTION.md` - Promotional text for App Store
- `XCODE_BUILD_PHASE_SETUP.md` - Manual setup instructions (backup)
- `APP_STORE_SUBMISSION_FIX.md` - This file

### Modified Files:
- `pubspec.yaml` - Version updated to 1.4.1+6
- `lib/features/settings/presentation/pages/settings_page.dart` - Version display updated
- `CHANGELOG.md` - Added v1.4.1 release notes
- `macos/Runner/Info.plist` - Added LSApplicationCategoryType
- `macos/Runner.xcodeproj/project.pbxproj` - Added run script build phase

## Troubleshooting

### If validation still fails:

1. **Check build log in Xcode:**
   - View > Navigators > Report Navigator
   - Look for "Fix Framework Structures" output
   - Verify script executed during build

2. **Manually verify framework structure:**
   ```bash
   ls -la "build/macos/Build/Products/Release/SitiPDF.app/Contents/Frameworks/objective_c.framework/"
   ```
   Should show symlinks:
   - `Resources -> Versions/A/Resources`
   - `objective_c -> Versions/Current/objective_c`

3. **Re-run build phase setup:**
   ```bash
   python3 add_build_phase.py
   ```

4. **Manual framework fix (last resort):**
   See XCODE_BUILD_PHASE_SETUP.md for manual fix instructions

## Additional Notes

- The fix ensures compatibility with App Store requirements
- Build phase runs during archive process
- All frameworks are processed, not just objective_c
- Debug builds are not affected
- The fix is permanent and will apply to all future builds

## Contact

If you encounter issues:
- Email: faisal@vsg-labs.com
- Review: APP_STORE_DESCRIPTION.md for store listing
- Check: XCODE_BUILD_PHASE_SETUP.md for detailed setup instructions

---

**Status:** Ready for App Store submission (with dSYM fix)
**Version:** 1.4.1 (build 6)
**Date:** January 27, 2026

---

## UPDATE: dSYM Upload Issue

After initial upload, received "Upload Symbols Failed" error for objective_c framework.

**Fix applied**: Created `macos/create_objective_c_dsym.sh` script and added "Create objective_c dSYM" build phase.

**IMPORTANT**: You must archive in Xcode (not use flutter build) for the dSYM to be included.

**See**: `DSYM_FIX_INSTRUCTIONS.md` for complete instructions.
