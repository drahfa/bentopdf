#!/bin/bash

# SitiPDF DMG Installer Creation Script
# Creates a distributable DMG file with the SitiPDF app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   SitiPDF DMG Installer Creator${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Configuration
APP_NAME="SitiPDF"
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//' | tr -d ' ')
BUILD_DIR="build/macos/Build/Products/Release"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="${APP_NAME}-${VERSION}"
OUTPUT_DIR="installers"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME.dmg"
TEMP_DMG="temp_${DMG_NAME}.dmg"
VOLUME_NAME="$APP_NAME $VERSION"

echo "Version: $VERSION"
echo "App Path: $APP_PATH"
echo "Output: $DMG_PATH"
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: $APP_PATH not found${NC}"
    echo "Please build the release version first:"
    echo "  flutter build macos --release"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking app signature...${NC}"
if codesign --verify --verbose "$APP_PATH" 2>/dev/null; then
    echo -e "${GREEN}✓ App is properly signed${NC}"
    codesign -dv --verbose=2 "$APP_PATH" 2>&1 | grep "Authority\|Identifier\|TeamIdentifier" || true
else
    echo -e "${YELLOW}⚠ App is not signed (ad-hoc signing)${NC}"
    echo "For distribution, sign with:"
    echo "  codesign --force --deep --sign \"Developer ID Application: Your Name\" \"$APP_PATH\""
fi
echo ""

# Create output directory
echo -e "${YELLOW}Step 2: Creating output directory...${NC}"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓ Directory created: $OUTPUT_DIR${NC}"
echo ""

# Remove old DMG if exists
if [ -f "$DMG_PATH" ]; then
    echo -e "${YELLOW}Step 3: Removing old DMG...${NC}"
    rm "$DMG_PATH"
    echo -e "${GREEN}✓ Old DMG removed${NC}"
    echo ""
fi

# Calculate app size and add buffer for DMG
echo -e "${YELLOW}Step 4: Calculating DMG size...${NC}"
APP_SIZE=$(du -sm "$APP_PATH" | cut -f1)
DMG_SIZE=$((APP_SIZE + 50))  # Add 50MB buffer
echo "App size: ${APP_SIZE}MB, DMG size: ${DMG_SIZE}MB"
echo ""

# Create temporary DMG
echo -e "${YELLOW}Step 5: Creating temporary DMG...${NC}"
hdiutil create -size ${DMG_SIZE}m -fs HFS+ -volname "$VOLUME_NAME" -ov "$TEMP_DMG"
echo -e "${GREEN}✓ Temporary DMG created${NC}"
echo ""

# Mount the DMG
echo -e "${YELLOW}Step 6: Mounting DMG...${NC}"
MOUNT_DIR=$(hdiutil attach -readwrite -noverify "$TEMP_DMG" | egrep '^/dev/' | sed 1q | awk '{print $3}')
echo "Mounted at: $MOUNT_DIR"
echo ""

# Copy app to DMG
echo -e "${YELLOW}Step 7: Copying $APP_NAME.app to DMG...${NC}"
cp -R "$APP_PATH" "$MOUNT_DIR/"
echo -e "${GREEN}✓ App copied${NC}"
echo ""

# Create Applications symlink
echo -e "${YELLOW}Step 8: Creating Applications symlink...${NC}"
ln -s /Applications "$MOUNT_DIR/Applications"
echo -e "${GREEN}✓ Symlink created${NC}"
echo ""

# Set custom icon position (optional - requires AppleScript)
echo -e "${YELLOW}Step 9: Configuring DMG appearance...${NC}"
cat > /tmp/dmg_setup.applescript << 'EOF'
tell application "Finder"
    tell disk "VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set position of item "APP_NAME.app" of container window to {150, 200}
        set position of item "Applications" of container window to {350, 200}
        update without registering applications
        delay 1
    end tell
end tell
EOF

# Replace placeholders in AppleScript
sed -i '' "s/VOLUME_NAME/$VOLUME_NAME/g" /tmp/dmg_setup.applescript
sed -i '' "s/APP_NAME/$APP_NAME/g" /tmp/dmg_setup.applescript

# Run AppleScript (may fail if Finder automation not permitted)
if osascript /tmp/dmg_setup.applescript 2>/dev/null; then
    echo -e "${GREEN}✓ DMG appearance configured${NC}"
else
    echo -e "${YELLOW}⚠ Could not configure appearance (Finder automation may not be permitted)${NC}"
fi
rm /tmp/dmg_setup.applescript
echo ""

# Unmount DMG
echo -e "${YELLOW}Step 10: Unmounting DMG...${NC}"
hdiutil detach "$MOUNT_DIR"
echo -e "${GREEN}✓ DMG unmounted${NC}"
echo ""

# Convert to compressed read-only DMG
echo -e "${YELLOW}Step 11: Converting to final DMG...${NC}"
hdiutil convert "$TEMP_DMG" -format UDZO -o "$DMG_PATH"
rm "$TEMP_DMG"
echo -e "${GREEN}✓ DMG compressed and finalized${NC}"
echo ""

# Get DMG info
DMG_FILE_SIZE=$(du -h "$DMG_PATH" | cut -f1)
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   DMG Creation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Output: $DMG_PATH"
echo "Size: $DMG_FILE_SIZE"
echo ""

# Check if DMG is signed/notarized
echo -e "${YELLOW}Checking DMG signature status...${NC}"
if codesign --verify --verbose "$DMG_PATH" 2>/dev/null; then
    echo -e "${GREEN}✓ DMG is signed${NC}"
else
    echo -e "${YELLOW}⚠ DMG is not signed${NC}"
fi

if spctl -a -t install "$DMG_PATH" 2>/dev/null; then
    echo -e "${GREEN}✓ DMG is notarized and will pass Gatekeeper${NC}"
else
    echo -e "${YELLOW}⚠ DMG is not notarized${NC}"
    echo ""
    echo "To notarize for distribution:"
    echo "  1. Sign the DMG:"
    echo "     codesign --sign \"Developer ID Application: Your Name\" \"$DMG_PATH\""
    echo ""
    echo "  2. Upload for notarization:"
    echo "     xcrun notarytool submit \"$DMG_PATH\" \\"
    echo "       --apple-id \"your@email.com\" \\"
    echo "       --password \"app-specific-password\" \\"
    echo "       --team-id \"YOUR_TEAM_ID\" \\"
    echo "       --wait"
    echo ""
    echo "  3. Once approved, staple the ticket:"
    echo "     xcrun stapler staple \"$DMG_PATH\""
fi

echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Test the DMG by mounting and installing the app"
echo "  2. Sign and notarize if distributing (see DISTRIBUTION.md)"
echo "  3. Distribute to users!"
echo ""
