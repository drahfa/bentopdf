# Xcode Build Phase Setup for App Store Validation

## Issue
Apple App Store validation requires framework bundles to follow a specific structure with symbolic links:
```
ITMS-90291: Malformed Framework - The framework bundle objective_c must contain a symbolic link 'Resources' -> 'Versions/Current/Resources'
```

## Solution
Add a Run Script build phase to fix framework structures before archiving.

## Steps to Add Build Script to Xcode

1. **Open Xcode Project**
   ```bash
   open macos/Runner.xcworkspace
   ```

2. **Select Runner Target**
   - In Xcode's project navigator (left sidebar), click on "Runner" (the blue project icon at the top)
   - In the main editor area, select the "Runner" target under TARGETS

3. **Add Run Script Phase**
   - Click the "Build Phases" tab at the top
   - Click the "+" button in the top left of the Build Phases section
   - Select "New Run Script Phase"

4. **Configure the Script**
   - Expand the newly created "Run Script" phase
   - In the script text box, paste:
     ```bash
     "$SRCROOT/fix_frameworks.sh"
     ```
   - Change the shell to: `/bin/bash`
   - **IMPORTANT:** Drag this "Run Script" phase to be positioned AFTER "Embed Frameworks" phase

5. **Name the Phase (Optional)**
   - Double-click on "Run Script" to rename it to "Fix Framework Structures"

6. **Save and Close**
   - Press Cmd+S to save
   - Close Xcode

## Verify the Fix

After adding the build phase:

1. Clean the build folder:
   ```bash
   flutter clean
   cd macos
   rm -rf Pods Podfile.lock
   cd ..
   ```

2. Rebuild:
   ```bash
   flutter pub get
   cd macos
   pod install
   cd ..
   flutter build macos --release
   ```

3. Archive in Xcode:
   - Open `macos/Runner.xcworkspace` in Xcode
   - Select "Any Mac (Apple Silicon, Intel)" as the destination
   - Product > Archive
   - Wait for archive to complete

4. Validate:
   - When archive completes, the Organizer window will open
   - Click "Distribute App"
   - Select "App Store Connect"
   - Click "Next" through the options
   - Click "Validate App" (instead of Upload)
   - Wait for validation to complete

The validation should now pass without the ITMS-90291 error.

## Alternative: Manual Fix (If Script Doesn't Work)

If the automated script doesn't work, you can manually fix the framework after building:

```bash
cd build/macos/Build/Products/Release/SitiPDF.app/Contents/Frameworks/objective_c.framework

# Create Versions structure
mkdir -p Versions/A

# Move existing content to Versions/A
mv objective_c Versions/A/
mv Resources Versions/A/ 2>/dev/null || true
mv Headers Versions/A/ 2>/dev/null || true
mv Modules Versions/A/ 2>/dev/null || true

# Create Current symlink
ln -sf A Versions/Current

# Create top-level symlinks
ln -sf Versions/Current/objective_c objective_c
ln -sf Versions/Current/Resources Resources
ln -sf Versions/Current/Headers Headers 2>/dev/null || true
ln -sf Versions/Current/Modules Modules 2>/dev/null || true
```

Then re-archive in Xcode.

## Troubleshooting

**Script not executing:**
- Verify the script is executable: `ls -l macos/fix_frameworks.sh`
- Should show `-rwxr-xr-x` permissions
- If not: `chmod +x macos/fix_frameworks.sh`

**Still getting validation error:**
- Check Xcode build log (View > Navigators > Report Navigator)
- Look for "Fixing framework structures" output
- Verify the script ran during the build

**Framework not found:**
- The script looks in `${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}`
- This should be: `build/macos/Build/Products/Release/SitiPDF.app/Contents/Frameworks`
- Verify frameworks exist at this path after building

## Notes

- This fix is specifically for the `objective_c` framework (transitive dependency from Flutter packages)
- The script will process ALL frameworks, ensuring they all have correct structure
- This only affects the release build used for App Store submission
- Debug builds are not affected
