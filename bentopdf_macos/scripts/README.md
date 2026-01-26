# SitiPDF Build & Distribution Scripts

This directory contains scripts to help build, sign, and distribute SitiPDF for macOS.

## Scripts Overview

### 1. `build_release.sh`
Builds a release version of SitiPDF with optional code signing.

**Usage:**
```bash
# Build with automatic certificate detection
./scripts/build_release.sh

# Build with specific certificate
./scripts/build_release.sh --sign "Developer ID Application: Dr. Ahmad Mohamad Ayob"

# Build without signing (testing only)
./scripts/build_release.sh --no-sign
```

**What it does:**
- Cleans previous builds
- Gets Flutter dependencies
- Builds release macOS app
- Signs with Developer ID (if available)
- Verifies code signature
- Reports app size and location

**Output:** `build/macos/Build/Products/Release/SitiPDF.app`

---

### 2. `create_dmg.sh`
Creates a distributable DMG installer from the built app.

**Usage:**
```bash
./scripts/create_dmg.sh
```

**Prerequisites:**
- App must be built first (run `build_release.sh`)

**What it does:**
- Reads version from `pubspec.yaml`
- Creates a DMG volume
- Copies SitiPDF.app to DMG
- Adds Applications folder symlink
- Configures DMG appearance (icon positions, window size)
- Compresses to final DMG
- Reports signing/notarization status

**Output:** `installers/SitiPDF-{version}.dmg`

**Example:** `installers/SitiPDF-1.3.0.dmg`

---

### 3. `notarize.sh`
Submits app or DMG to Apple for notarization.

**Usage:**
```bash
./scripts/notarize.sh <file> <apple-id> <team-id>
```

**Example:**
```bash
./scripts/notarize.sh installers/SitiPDF-1.3.0.dmg developer@vsg.com ABCD123456
```

**Prerequisites:**
- File must be signed with Developer ID certificate
- Apple Developer account with Team ID
- App-specific password from appleid.apple.com

**What it does:**
- Verifies file is properly signed
- Creates ZIP if needed (.app files)
- Submits to Apple notarization service
- Waits for notarization to complete (5-15 minutes)
- Staples notarization ticket to file
- Verifies Gatekeeper will accept the file

**Getting App-Specific Password:**
1. Go to https://appleid.apple.com
2. Sign-In and Security → App-Specific Passwords
3. Generate new password named "SitiPDF Notarization"
4. Copy the password (format: xxxx-xxxx-xxxx-xxxx)

**Finding Team ID:**
- Go to https://developer.apple.com/account
- Look for "Team ID" in Membership Details

---

## Complete Distribution Workflow

### For First-Time Distribution:

1. **Get Distribution Certificate**
   - Log in to https://developer.apple.com/account/resources/certificates/
   - Create "Developer ID Application" certificate
   - Download and install in Keychain

2. **Build Release Version**
   ```bash
   ./scripts/build_release.sh
   ```

3. **Create DMG Installer**
   ```bash
   ./scripts/create_dmg.sh
   ```

4. **Notarize with Apple**
   ```bash
   ./scripts/notarize.sh installers/SitiPDF-1.3.0.dmg your@email.com YOUR_TEAM_ID
   ```

5. **Test on Clean Mac**
   - Mount DMG
   - Drag to Applications
   - Launch app
   - Should open without warnings

6. **Distribute!**
   - Upload DMG to website
   - Share with users
   - Users can install without warnings

### For Updates (After Initial Setup):

```bash
# 1. Update version in pubspec.yaml
# 2. Update CHANGELOG.md

# 3. Build, package, and notarize
./scripts/build_release.sh
./scripts/create_dmg.sh
./scripts/notarize.sh installers/SitiPDF-{version}.dmg your@email.com YOUR_TEAM_ID

# 4. Distribute
```

---

## Troubleshooting

### "No Developer ID certificate found"
- You need to enroll in Apple Developer Program ($99/year)
- Create Developer ID Application certificate
- See DISTRIBUTION.md for detailed instructions

### Build fails with signing error
- Check certificate is valid:
  ```bash
  security find-identity -v -p codesigning
  ```
- Ensure certificate isn't expired
- Try building without signing:
  ```bash
  ./scripts/build_release.sh --no-sign
  ```

### DMG creation fails
- Ensure app was built:
  ```bash
  ls build/macos/Build/Products/Release/SitiPDF.app
  ```
- Check disk space
- Try manually:
  ```bash
  flutter build macos --release
  ./scripts/create_dmg.sh
  ```

### Notarization fails
- Verify app is signed:
  ```bash
  codesign --verify --verbose build/macos/Build/Products/Release/SitiPDF.app
  ```
- Check hardened runtime is enabled:
  ```bash
  codesign -dv --verbose=4 build/macos/Build/Products/Release/SitiPDF.app | grep runtime
  ```
- Get detailed error log:
  ```bash
  xcrun notarytool log <submission-id> --apple-id <email> --password <password> --team-id <team-id>
  ```

### "App is damaged" error
- App needs notarization
- Run notarize.sh script
- Or user needs to: System Settings → Privacy & Security → Allow

---

## Quick Reference

### Check Available Certificates
```bash
security find-identity -v -p codesigning
```

### Verify App Signature
```bash
codesign --verify --verbose build/macos/Build/Products/Release/SitiPDF.app
codesign -dv --verbose=2 build/macos/Build/Products/Release/SitiPDF.app
```

### Check Notarization Status
```bash
spctl -a -t install installers/SitiPDF-1.3.0.dmg
xcrun stapler validate installers/SitiPDF-1.3.0.dmg
```

### Manual Signing
```bash
codesign --force --deep --options runtime \
  --sign "Developer ID Application: Your Name" \
  build/macos/Build/Products/Release/SitiPDF.app
```

---

## Environment Setup

### Required Tools
- ✅ macOS (for building macOS apps)
- ✅ Xcode (installed via App Store)
- ✅ Flutter SDK
- ✅ CocoaPods (`sudo gem install cocoapods`)

### For Distribution
- 📋 Apple Developer Account ($99/year)
- 📋 Developer ID Application Certificate
- 📋 Apple ID app-specific password
- 📋 Team ID

---

## Additional Resources

- **Full Documentation**: See `DISTRIBUTION.md` in project root
- **Apple Code Signing**: https://developer.apple.com/support/code-signing/
- **Notarization Guide**: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
- **Developer Portal**: https://developer.apple.com/account/

---

## Support

If you encounter issues:
1. Check DISTRIBUTION.md for detailed troubleshooting
2. Verify all prerequisites are met
3. Check Apple Developer account status
4. Review script output for error messages
