# SitiPDF Notarization Setup Guide

## Your Information
- **Apple ID**: ahmadfaisal9@yahoo.com
- **Team ID**: NT3PV9G766
- **Current Certificate**: Apple Development (testing only)
- **Needed**: Developer ID Application certificate

---

## Step 1: Create Developer ID Application Certificate

### 1.1 Generate Certificate Signing Request (CSR)

1. Open **Keychain Access** (Applications → Utilities → Keychain Access)
2. From menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. Fill in the form:
   - **User Email Address**: `ahmadfaisal9@yahoo.com`
   - **Common Name**: `Dr. Ahmad Mohamad Ayob` (or your name)
   - **Request**: Select **"Saved to disk"**
   - **Let me specify key pair information**: Check this box
4. Click **Continue**
5. Save as: `SitiPDF_DeveloperID.certSigningRequest`
6. Click **Continue** then **Done**

### 1.2 Request Certificate from Apple

1. Go to: https://developer.apple.com/account/resources/certificates/add
2. Sign in with: **ahmadfaisal9@yahoo.com**
3. Select: **Developer ID Application**
4. Click **Continue**
5. Upload the CSR file you just created: `SitiPDF_DeveloperID.certSigningRequest`
6. Click **Continue**
7. **Download** the certificate file (something like `developerID_application.cer`)
8. **Double-click** the downloaded certificate to install it in Keychain

### 1.3 Verify Installation

Open Terminal and run:
```bash
security find-identity -v -p codesigning
```

You should now see something like:
```
1) XXXXX "Developer ID Application: Dr. Ahmad Mohamad Ayob (XXXXX)"
2) XXXXX "Apple Development: Dr. Ahmad Mohamad Ayob (22LEPD7YA3)"
```

---

## Step 2: Create App-Specific Password

### 2.1 Generate Password

1. Go to: https://appleid.apple.com
2. Sign in with: **ahmadfaisal9@yahoo.com**
3. Navigate to: **Sign-In and Security**
4. Find: **App-Specific Passwords**
5. Click the **"+"** button
6. Enter name: `SitiPDF Notarization`
7. Click **Create**
8. **Copy the password** - it will be in format: `xxxx-xxxx-xxxx-xxxx`
9. **Save it securely** - you'll need it for notarization

⚠️ **Important**: This password is shown only once! Save it now.

---

## Step 3: Build and Sign the Release

Once you have the Developer ID Application certificate installed:

```bash
cd /Users/drahfa/GitHub/bentopdf/bentopdf_macos

# Build with automatic signing (will detect Developer ID certificate)
./scripts/build_release.sh

# Create DMG installer
./scripts/create_dmg.sh
```

---

## Step 4: Notarize with Apple

```bash
./scripts/notarize.sh \
  installers/SitiPDF-1.3.0.dmg \
  ahmadfaisal9@yahoo.com \
  NT3PV9G766
```

When prompted, enter the **app-specific password** you created in Step 2.

The script will:
- Verify the DMG is signed
- Submit to Apple for notarization
- Wait for approval (usually 5-15 minutes)
- Staple the notarization ticket
- Verify it will pass Gatekeeper

---

## Step 5: Distribute

Once notarization is complete:
- Your DMG is at: `installers/SitiPDF-1.3.0.dmg`
- Users can install without warnings
- Upload to your website or distribute via download

---

## Quick Checklist

- [ ] Create Certificate Signing Request (CSR) in Keychain Access
- [ ] Request Developer ID Application certificate from Apple Developer
- [ ] Download and install certificate (double-click .cer file)
- [ ] Verify certificate with: `security find-identity -v -p codesigning`
- [ ] Create app-specific password at appleid.apple.com
- [ ] Save the app-specific password securely
- [ ] Build release: `./scripts/build_release.sh`
- [ ] Create DMG: `./scripts/create_dmg.sh`
- [ ] Notarize: `./scripts/notarize.sh installers/SitiPDF-1.3.0.dmg ahmadfaisal9@yahoo.com NT3PV9G766`
- [ ] Test on clean Mac
- [ ] Distribute!

---

## Cost & Requirements

**Apple Developer Program**: $99/year
- Enrollment URL: https://developer.apple.com/programs/enroll/

**Note**: You need an active Apple Developer Program membership to create distribution certificates and notarize apps.

---

## Troubleshooting

### "No valid signing identities found"
- Make sure you downloaded and installed the certificate
- Double-click the .cer file to install in Keychain
- Verify with: `security find-identity -v -p codesigning`

### "Certificate request failed"
- Ensure you're logged into https://developer.apple.com with: ahmadfaisal9@yahoo.com
- Check your Apple Developer Program membership is active
- Try again with a new CSR

### "App-specific password doesn't work"
- Make sure you copied it correctly (format: xxxx-xxxx-xxxx-xxxx)
- Don't use your regular Apple ID password
- Create a new app-specific password if needed

### "Notarization failed"
- Check the app is signed with Developer ID (not Development certificate)
- Review the notarization log for specific errors
- Ensure hardened runtime is enabled

---

## Support

If you encounter issues:
1. Check DISTRIBUTION.md for detailed information
2. Review the error messages carefully
3. Check Apple Developer account status
4. Ensure certificates haven't expired

---

## Current Status

✅ **Ready for setup:**
- Apple ID: ahmadfaisal9@yahoo.com
- Team ID: NT3PV9G766
- Development certificate: Installed
- Build scripts: Ready

⏳ **Needed:**
- Developer ID Application certificate
- App-specific password
- Active Apple Developer Program membership

Once these are set up, you can notarize and distribute SitiPDF!
