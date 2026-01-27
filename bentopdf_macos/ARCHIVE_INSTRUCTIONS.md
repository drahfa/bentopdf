# How to Archive for App Store - Build 7

## Current Status

✅ **Flutter build completed** - App built successfully
✅ **Fix script verified** - Symlinks can be fixed correctly
✅ **Version updated** - Build 7 ready
⏭️ **Next**: Archive in Xcode to apply fixes

## IMPORTANT: Why You Must Archive in Xcode

The fix scripts (`fix_frameworks.sh` and `create_objective_c_dsym.sh`) are **Xcode build phases** that:
- ✅ Run during **Xcode archive** process
- ❌ Do NOT run during **`flutter build`** command

This is why we must use Xcode for the final archive.

## Step-by-Step Archive Instructions

### Step 1: Open Workspace in Xcode

```bash
cd /Users/drahfa/GitHub/bentopdf/bentopdf_macos
open macos/Runner.xcworkspace
```

**Note**: Open the `.xcworkspace` file, NOT the `.xcodeproj` file.

### Step 2: Configure Xcode for Archive

1. At the top of Xcode window, click on the device selector (next to "Runner")
2. Select: **Any Mac (Apple Silicon, Intel)**
3. Verify "Runner" scheme is selected (not "Pods-Runner")

### Step 3: Archive the App

1. Menu bar: **Product > Archive**
2. Wait for the build to complete (2-3 minutes)
3. Xcode Organizer will open automatically when done

**During archiving**, the following scripts run automatically:
- ✅ "Fix Framework Structures" - Corrects symlinks
- ✅ "Create objective_c dSYM" - Generates symbol file

### Step 4: Verify the Fix (CRITICAL)

**Before uploading**, verify the symlink was fixed:

Open Terminal and run:
```bash
# Find the latest archive
LATEST=$(find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -type d -exec stat -f "%m %N" {} \; | sort -rn | head -1 | cut -d' ' -f2-)

# Check the objective_c Resources symlink
echo "Archive: $LATEST"
echo ""
ls -la "$LATEST/Products/Applications/SitiPDF.app/Contents/Frameworks/objective_c.framework/" | grep Resources
```

**Expected output**:
```
Resources -> Versions/Current/Resources
```

**If you see** `Versions/A/Resources` instead:
- The script didn't run
- Check troubleshooting section below

### Step 5: Validate in Xcode Organizer

With the archive selected in Organizer:
1. Click **Distribute App**
2. Select **App Store Connect**
3. Click **Next**
4. Select **Validate App**
5. Click **Next** through the options
6. Wait for validation

**Expected result**: ✅ Validation passes without ITMS-90291 error

### Step 6: Upload to App Store Connect

Once validation passes:
1. In Organizer, click **Distribute App** again
2. Select **App Store Connect**
3. Select **Upload** (not Validate this time)
4. Click **Next** through options
5. Wait for upload to complete

**Expected results**:
- ✅ Upload succeeds
- ⚠️ "Upload Symbols Failed" warning (expected, safe to ignore)

### Step 7: Submit for Review

1. Go to https://appstoreconnect.apple.com
2. Navigate to: **My Apps > SitiPDF > App Store > 1.4.1**
3. In the **Build** section, click **Select a build before you submit your app**
4. Choose build **1.4.1 (7)**
5. Complete any required fields
6. Click **Submit for Review**

## Troubleshooting

### If Xcode shows "ephemeral file not found" errors:

Already fixed by running `flutter pub get` and `pod install`.

### If build fails in Xcode:

1. Close Xcode
2. Run:
   ```bash
   flutter clean
   flutter pub get
   cd macos && pod install && cd ..
   ```
3. Reopen Xcode and try again

### If script doesn't run during archive:

Check that build phases exist:
1. In Xcode, click on "Runner" project (blue icon)
2. Select "Runner" target
3. Click "Build Phases" tab
4. Verify these phases exist:
   - "Fix Framework Structures"
   - "Create objective_c dSYM"

If missing, run:
```bash
python3 add_build_phase.py
python3 add_dsym_build_phase.py
```

Then close and reopen Xcode.

### If validation still fails with ITMS-90291:

The symlink wasn't fixed. Check:
1. Build log in Xcode (View > Navigators > Report Navigator)
2. Search for "Fix Framework Structures"
3. Should see output: "✓ Fixed Resources symlink"

If not found, the script didn't run. Verify build phases exist.

## What Should Happen

| Step | Status |
|------|--------|
| Open workspace | ✅ Done |
| Select "Any Mac" | ✅ Configure |
| Archive | ⏳ In progress (2-3 min) |
| Scripts run | ✅ Automatic |
| Organizer opens | ✅ Automatic |
| Verify symlink | ✅ Check manually |
| Validate | ✅ Should pass |
| Upload | ✅ Should succeed |
| Submit | ✅ In App Store Connect |

## Common Xcode Archive Issues

### Issue: "Signing requires a development team"
**Solution**: Select your development team in project settings

### Issue: "No such module 'Flutter'"
**Solution**:
```bash
flutter clean
flutter pub get
cd macos && pod install && cd ..
```
Then try again.

### Issue: "Archive is not exportable"
**Solution**: Make sure you're archiving for "Any Mac", not a specific device

### Issue: Build phase warnings
**Warning**: "Run script will be run during every build"
**Impact**: None - this is just informational

## Summary

✅ **Build completed** - App is ready
✅ **Fix script works** - Verified manually
⏭️ **Next**: Archive in Xcode
⏭️ **Then**: Verify symlink → Validate → Upload

---

**Quick Commands**:
```bash
# Open Xcode
open macos/Runner.xcworkspace

# After archive, verify symlink
LATEST=$(find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -type d -exec stat -f "%m %N" {} \; | sort -rn | head -1 | cut -d' ' -f2-)
ls -la "$LATEST/Products/Applications/SitiPDF.app/Contents/Frameworks/objective_c.framework/" | grep Resources
```

**Version**: 1.4.1 (build 7)
**Status**: Ready to archive
**Date**: January 27, 2026
