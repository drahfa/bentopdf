# Upload Checklist - Build 7

## Issue Fixed

✅ **ITMS-90291**: Framework symlink structure corrected
✅ **Script updated**: Now fixes existing frameworks properly
✅ **Build number**: Updated to 7
✅ **Ready**: To archive and upload

## Quick Upload Steps

### 1. Archive in Xcode

```bash
cd /Users/drahfa/GitHub/bentopdf/bentopdf_macos
open macos/Runner.xcworkspace
```

In Xcode:
- Select: **Any Mac (Apple Silicon, Intel)**
- Menu: **Product > Archive**
- **Wait for completion**

### 2. Verify Symlink (CRITICAL)

When archive completes, verify the fix worked:

```bash
# Find latest archive and check symlink
LATEST=$(find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -type d -exec stat -f "%m %N" {} \; | sort -rn | head -1 | cut -d' ' -f2-)
ls -la "$LATEST/Products/Applications/SitiPDF.app/Contents/Frameworks/objective_c.framework/" | grep Resources
```

**Must show**:
```
Resources -> Versions/Current/Resources ✓
```

**NOT**:
```
Resources -> Versions/A/Resources ✗
```

### 3. Validate in Xcode

In Organizer:
- Click **Distribute App**
- Select **App Store Connect**
- Click **Validate App**
- Wait for validation

**Expected**: ✅ No ITMS-90291 error

### 4. Upload

- Click **Distribute App** again
- Select **Upload**
- Complete upload

**Expected**: ✅ Upload succeeds (symbol warning ok)

### 5. Submit

1. Go to https://appstoreconnect.apple.com
2. SitiPDF → Version 1.4.1
3. Select build 7
4. Submit for review

## Success Criteria

✅ Archive created
✅ Symlink verified: `Versions/Current/Resources`
✅ Validation passed: No ITMS-90291
✅ Upload succeeded
✅ Build 7 available in App Store Connect

## If Validation Fails Again

1. Check build log for "Fix Framework Structures" output
2. Verify script ran and reported "✓ Fixed Resources symlink"
3. Check `FINAL_FIX_ITMS_90291.md` for detailed troubleshooting

## Version Info

- **Version**: 1.4.1
- **Build**: 7
- **Previous build**: 6 (rejected)
- **Fix**: Framework symlink structure

---

**Start here**: Archive in Xcode → Verify symlink → Upload
