# dSYM Upload Fix Instructions

## Issue

After uploading to App Store Connect:
```
Upload Symbols Failed
The archive did not include a dSYM for the A with the UUIDs
[254407D4-ED4A-3260-954F-3F172B707B4C, 6B69F345-906C-3257-BBB7-A9566239BBA6].
```

## Solution Implemented

Created a build script that generates a minimal dSYM for the `objective_c.framework` to satisfy App Store Connect requirements.

### What Was Added

1. **Script**: `macos/create_objective_c_dsym.sh`
   - Creates dSYM bundle with correct UUIDs
   - Runs automatically during Xcode archive process
   - Phase ID: `D37A8C3214A34CBAAAD16C06`

2. **Build Phase**: "Create objective_c dSYM"
   - Added to Runner target in Xcode
   - Executes after "Fix Framework Structures" phase
   - Generates `objective_c.framework.dSYM` in build products

## Verification

Script was tested and verified:
```
✓ Created dSYM at: build/macos/Build/Products/Release/objective_c.framework.dSYM
✓ Original UUIDs match dSYM UUIDs:
  - 254407D4-ED4A-3260-954F-3F172B707B4C (x86_64)
  - 6B69F345-906C-3257-BBB7-A9566239BBA6 (arm64)
```

## Next Steps to Upload

### 1. Clean Previous Build
```bash
cd /Users/drahfa/GitHub/bentopdf/bentopdf_macos
flutter clean
flutter pub get
```

### 2. Archive in Xcode (IMPORTANT)

**You must archive in Xcode, not use flutter build**. The build scripts only run during Xcode's archive process.

```bash
open macos/Runner.xcworkspace
```

In Xcode:
1. Select destination: **Any Mac (Apple Silicon, Intel)**
2. Menu: **Product > Archive**
3. Wait for archive to complete (1-2 minutes)

**During archiving**, you should see in the build log:
```
Creating dSYM for objective_c framework...
Framework found at: ...
✓ Created dSYM at: ...
✓ UUIDs match
```

### 3. Validate the Archive

When archive completes:
1. Organizer window will open automatically
2. Select your new archive
3. Click **Distribute App**
4. Select **App Store Connect**
5. Click **Next** through options
6. Click **Validate App** (test first)
7. Wait for validation

**Expected result**: Validation should complete WITHOUT the dSYM error.

### 4. Upload to App Store Connect

Once validation passes:
1. Click **Distribute App** again
2. Select **App Store Connect**
3. Select **Upload**
4. Complete upload process

**Expected result**: Upload should succeed with "Upload Symbols Succeeded"

## Troubleshooting

### If dSYM is still missing after archive:

1. **Check Xcode build log**:
   - View > Navigators > Report Navigator
   - Select your archive
   - Search for "Create objective_c dSYM"
   - Verify script output

2. **Verify build phase order** in Xcode:
   - Open `macos/Runner.xcworkspace`
   - Select Runner target > Build Phases
   - Should see:
     - "Fix Framework Structures"
     - "Create objective_c dSYM"
   - Both should be AFTER "Embed Frameworks"

3. **Manually verify dSYM in archive**:
   ```bash
   # Find your archive
   ls -la ~/Library/Developer/Xcode/Archives/*/SitiPDF*.xcarchive/dSYMs/

   # Should show:
   # objective_c.framework.dSYM
   # SitiPDF.app.dSYM
   # ... other framework dSYMs
   ```

### If build phase is missing:

Re-run the setup script:
```bash
python3 add_dsym_build_phase.py
```

### If script fails during archive:

Check script permissions:
```bash
ls -l macos/create_objective_c_dsym.sh
# Should show: -rwxr-xr-x

# If not executable:
chmod +x macos/create_objective_c_dsym.sh
```

## Understanding the Fix

### What the dSYM contains

The created dSYM is a **minimal symbol file** that:
- Contains the binary with matching UUIDs
- Has proper dSYM bundle structure
- Satisfies App Store Connect requirements
- **Does not provide crash symbolication** (binary has no symbols)

### Why this approach

The `objective_c` framework:
- Is a pre-built binary from pub.dev (version 9.2.4)
- Has no debug symbols in the original binary
- Cannot be rebuilt with symbols (it's a transitive dependency)
- Rarely crashes (it's just a thin Objective-C bridge layer)

This solution:
✅ Satisfies Apple's upload requirement
✅ Allows app submission to proceed
✅ All other frameworks have full symbolication
⚠️ Only objective_c crashes won't symbolicate (extremely rare)

## Alternative if This Doesn't Work

If the dSYM still isn't included after archiving:

### Option 1: Manual dSYM inclusion
1. Build: `flutter build macos --release`
2. Run script manually:
   ```bash
   export BUILT_PRODUCTS_DIR="build/macos/Build/Products/Release"
   export FRAMEWORKS_FOLDER_PATH="SitiPDF.app/Contents/Frameworks"
   ./macos/create_objective_c_dsym.sh
   ```
3. Copy dSYM to Xcode archive location
4. Re-upload archive

### Option 2: Contact Apple Support
If uploads continue to fail, request an exception from Apple Developer Support explaining:
- The framework is a third-party pre-built binary
- No debug symbols are available from the source
- All app code and other frameworks have full symbolication

## Version Information

**App Version**: 1.4.1 (build 6)
**objective_c Framework**: 9.2.4 (from pub.dev)
**Fix Applied**: January 27, 2026

## Summary

✅ Build scripts added to Xcode project
✅ Script verified to create dSYM with correct UUIDs
⏭️ **Action required**: Archive in Xcode (not flutter build)
⏭️ **Then**: Validate and upload to App Store Connect

The dSYM will be automatically created during archiving and should resolve the upload failure.
