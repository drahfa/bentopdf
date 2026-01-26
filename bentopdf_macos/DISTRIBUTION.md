# SitiPDF macOS Distribution Guide

## Prerequisites

### 1. Apple Developer Account
- Enroll in Apple Developer Program ($99/year)
- URL: https://developer.apple.com/programs/

### 2. Required Certificates

For **direct distribution** (outside Mac App Store):
- **Developer ID Application Certificate**
  - Used for code signing apps distributed outside the Mac App Store
  - Allows apps to pass Gatekeeper verification
  - Get from: Apple Developer Portal → Certificates → Create → Developer ID Application

For **Mac App Store** distribution:
- **Apple Distribution Certificate**
  - Used for apps submitted to the Mac App Store
  - Get from: Apple Developer Portal → Certificates → Create → Apple Distribution

### Currently Available Certificate
```
Apple Development: Dr. Ahmad Mohamad Ayob (22LEPD7YA3)
```
✅ Good for development and testing
❌ Not suitable for distribution

## Distribution Options

### Option 1: Direct Distribution (Recommended for SitiPDF)
**Pros:**
- Full control over distribution
- No App Store review process
- Can distribute immediately
- Keep 100% of revenue

**Cons:**
- Manual updates (no automatic App Store updates)
- Users must allow apps from identified developers
- No App Store discoverability

**Requirements:**
1. Developer ID Application Certificate
2. Notarization with Apple
3. DMG or PKG installer

### Option 2: Mac App Store Distribution
**Pros:**
- Automatic updates
- App Store trust and discoverability
- Easier installation for users

**Cons:**
- App Store review (1-3 days typically)
- Apple takes 30% commission
- Sandboxing restrictions may limit PDF features
- More restrictive entitlements

**Requirements:**
1. Apple Distribution Certificate
2. Mac App Store provisioning profile
3. App Store submission via App Store Connect

## Setting Up Distribution

### Step 1: Get Distribution Certificate

#### For Direct Distribution (Developer ID):
1. Go to https://developer.apple.com/account/resources/certificates/
2. Click "+" to create new certificate
3. Select "Developer ID Application"
4. Follow CSR creation process:
   ```bash
   # Open Keychain Access → Certificate Assistant → Request Certificate from Certificate Authority
   # Enter: Dr. Ahmad Mohamad Ayob's email
   # Select: Saved to disk
   # Continue and save the CSR file
   ```
5. Upload CSR to Apple Developer Portal
6. Download and double-click the certificate to install

#### For Mac App Store:
1. Similar process but select "Apple Distribution" certificate

### Step 2: Update Xcode Project Signing

Current configuration: Ad-hoc signing (`CODE_SIGN_IDENTITY = "-"`)

Update to proper signing in `macos/Runner.xcodeproj/project.pbxproj`:

For Debug builds (keep as-is):
```
CODE_SIGN_IDENTITY = "-";
```

For Release builds (after getting certificate):
```
CODE_SIGN_IDENTITY = "Developer ID Application: Dr. Ahmad Mohamad Ayob";
DEVELOPMENT_TEAM = "YOUR_TEAM_ID";
CODE_SIGN_STYLE = Manual;
```

### Step 3: Update Entitlements

**Current entitlements** (`macos/Runner/Release.entitlements`):
- File access
- Network
- Camera (for signature capture)

**For Direct Distribution**: Keep as-is (no sandbox)

**For Mac App Store**: Must enable App Sandbox:
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
```

### Step 4: Build for Release

```bash
# Clean build
flutter clean

# Build release version
flutter build macos --release

# Output location:
# build/macos/Build/Products/Release/SitiPDF.app
```

### Step 5: Code Sign Manually (if needed)

```bash
# Sign the app
codesign --force --deep --sign "Developer ID Application: Dr. Ahmad Mohamad Ayob" \
  build/macos/Build/Products/Release/SitiPDF.app

# Verify signature
codesign --verify --verbose build/macos/Build/Products/Release/SitiPDF.app

# Check entitlements
codesign -d --entitlements - build/macos/Build/Products/Release/SitiPDF.app
```

### Step 6: Notarize with Apple

**Required for direct distribution** to avoid Gatekeeper warnings.

```bash
# 1. Create a ZIP or DMG of the signed app
ditto -c -k --keepParent build/macos/Build/Products/Release/SitiPDF.app SitiPDF.zip

# 2. Upload to Apple for notarization
xcrun notarytool submit SitiPDF.zip \
  --apple-id "your-apple-id@email.com" \
  --password "app-specific-password" \
  --team-id "YOUR_TEAM_ID" \
  --wait

# 3. Once notarization succeeds, staple the ticket
xcrun stapler staple build/macos/Build/Products/Release/SitiPDF.app
```

**Note**: Need to create App-Specific Password:
1. Go to https://appleid.apple.com
2. Sign in with Apple ID
3. App-Specific Passwords → Generate

### Step 7: Create DMG Installer

We've included a script: `scripts/create_dmg.sh`

```bash
# Run DMG creation script
./scripts/create_dmg.sh

# Output: installers/SitiPDF-1.3.0.dmg
```

## Distribution Checklist

### Before Distribution
- [ ] Version number updated in pubspec.yaml
- [ ] Version updated in Settings page
- [ ] CHANGELOG.md updated
- [ ] All features tested on clean macOS installation
- [ ] App icon properly set
- [ ] Bundle identifier is unique (com.vsg.sitipdf)
- [ ] Copyright information updated

### Developer ID Distribution
- [ ] Developer ID Application certificate installed
- [ ] Xcode project configured for Release signing
- [ ] App built in Release mode
- [ ] App code signed with Developer ID
- [ ] App notarized with Apple
- [ ] Notarization ticket stapled to app
- [ ] DMG created with signed app
- [ ] DMG tested on clean Mac

### Mac App Store Distribution
- [ ] Apple Distribution certificate installed
- [ ] App Sandbox enabled in entitlements
- [ ] Provisioning profile created
- [ ] App built with App Store configuration
- [ ] App uploaded via Transporter or Xcode
- [ ] App metadata submitted in App Store Connect
- [ ] Screenshots prepared (1280x800, 1440x900, 2560x1600, 2880x1800)
- [ ] Privacy policy URL provided
- [ ] App passed App Store review

## Current Status

**Bundle ID**: `com.vsg.sitipdf`
**Product Name**: `SitiPDF`
**Version**: `1.3.0` (build 4)
**Copyright**: `Copyright © 2026 VSG. All rights reserved.`
**Publisher**: `VSG Labs`

**Available Certificates**:
- ✅ Apple Development (for testing)
- ❌ Developer ID Application (needed for distribution)
- ❌ Apple Distribution (needed for Mac App Store)

**Next Steps**:
1. Decide: Direct Distribution or Mac App Store?
2. Get appropriate distribution certificate
3. Update Xcode project signing configuration
4. Build and sign release version
5. Notarize with Apple
6. Create DMG installer
7. Distribute!

## Troubleshooting

### "App is damaged and can't be opened"
- App needs to be notarized
- Run notarization process

### "App can't be opened because the developer cannot be verified"
- User needs to right-click → Open (first time only)
- Or: System Settings → Privacy & Security → Allow anyway

### Code signing fails
- Check certificate is valid: `security find-identity -v -p codesigning`
- Check certificate expiration date
- Ensure correct team ID

### Notarization fails
- Check app is properly signed: `codesign --verify --verbose YourApp.app`
- Check for hardened runtime: `codesign -dv --verbose=4 YourApp.app | grep runtime`
- Review notarization log for specific issues

## Resources

- Apple Developer Portal: https://developer.apple.com/account/
- Code Signing Guide: https://developer.apple.com/support/code-signing/
- Notarization Guide: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
