#!/bin/bash

# SitiPDF Notarization Script
# Submits app or DMG to Apple for notarization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   SitiPDF Notarization${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check for required arguments
if [ $# -lt 3 ]; then
    echo -e "${RED}Usage: $0 <file.dmg|file.app> <apple-id> <team-id>${NC}"
    echo ""
    echo "Arguments:"
    echo "  file          Path to DMG or .app to notarize"
    echo "  apple-id      Your Apple ID email"
    echo "  team-id       Your Apple Developer Team ID"
    echo ""
    echo "Example:"
    echo "  $0 installers/SitiPDF-1.3.0.dmg developer@vsg.com ABCD123456"
    echo ""
    echo "Notes:"
    echo "  - You need an app-specific password from appleid.apple.com"
    echo "  - The script will prompt for the password (do not pass it as argument)"
    echo "  - Find your Team ID at: https://developer.apple.com/account"
    exit 1
fi

FILE_PATH="$1"
APPLE_ID="$2"
TEAM_ID="$3"

# Verify file exists
if [ ! -e "$FILE_PATH" ]; then
    echo -e "${RED}Error: File not found: $FILE_PATH${NC}"
    exit 1
fi

# Get file extension
FILE_EXT="${FILE_PATH##*.}"
FILE_NAME=$(basename "$FILE_PATH")

echo "File: $FILE_NAME"
echo "Apple ID: $APPLE_ID"
echo "Team ID: $TEAM_ID"
echo ""

# Check if file is signed
echo -e "${YELLOW}Checking code signature...${NC}"
if codesign --verify --verbose "$FILE_PATH" 2>/dev/null; then
    echo -e "${GREEN}✓ File is properly signed${NC}"

    # Display signature info
    echo ""
    echo "Signature details:"
    codesign -dv --verbose=2 "$FILE_PATH" 2>&1 | grep -E "Authority|Identifier|TeamIdentifier|runtime" || true
    echo ""
else
    echo -e "${RED}✗ File is not properly signed${NC}"
    echo ""
    echo "Please sign the file first with:"
    if [ "$FILE_EXT" = "dmg" ]; then
        echo "  codesign --sign \"Developer ID Application: Your Name\" \"$FILE_PATH\""
    else
        echo "  codesign --force --deep --options runtime --sign \"Developer ID Application: Your Name\" \"$FILE_PATH\""
    fi
    exit 1
fi

# Prompt for app-specific password
echo -e "${YELLOW}App-Specific Password Required${NC}"
echo ""
echo "You need an app-specific password from Apple ID:"
echo "  1. Go to: https://appleid.apple.com"
echo "  2. Sign in with your Apple ID ($APPLE_ID)"
echo "  3. Navigate to: Sign-In and Security → App-Specific Passwords"
echo "  4. Click '+' to generate a new password"
echo "  5. Name it 'SitiPDF Notarization'"
echo "  6. Copy the password (format: xxxx-xxxx-xxxx-xxxx)"
echo ""
read -sp "Enter app-specific password: " APP_PASSWORD
echo ""
echo ""

if [ -z "$APP_PASSWORD" ]; then
    echo -e "${RED}Error: Password cannot be empty${NC}"
    exit 1
fi

# Create a temporary ZIP if it's an app bundle
SUBMIT_FILE="$FILE_PATH"
CLEANUP_ZIP=false

if [ "$FILE_EXT" = "app" ]; then
    echo -e "${YELLOW}Creating ZIP archive for submission...${NC}"
    ZIP_NAME="${FILE_PATH%.app}.zip"
    ditto -c -k --keepParent "$FILE_PATH" "$ZIP_NAME"
    SUBMIT_FILE="$ZIP_NAME"
    CLEANUP_ZIP=true
    echo -e "${GREEN}✓ ZIP created: $ZIP_NAME${NC}"
    echo ""
fi

# Submit for notarization
echo -e "${YELLOW}Submitting to Apple for notarization...${NC}"
echo "This may take 5-15 minutes. Please wait..."
echo ""

NOTARIZE_OUTPUT=$(xcrun notarytool submit "$SUBMIT_FILE" \
    --apple-id "$APPLE_ID" \
    --password "$APP_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait 2>&1)

echo "$NOTARIZE_OUTPUT"
echo ""

# Check if notarization was successful
if echo "$NOTARIZE_OUTPUT" | grep -q "status: Accepted"; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   Notarization Successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Extract submission ID for reference
    SUBMISSION_ID=$(echo "$NOTARIZE_OUTPUT" | grep "id:" | head -1 | awk '{print $2}')
    echo "Submission ID: $SUBMISSION_ID"
    echo ""

    # Staple the ticket
    echo -e "${YELLOW}Stapling notarization ticket...${NC}"

    # Determine what to staple (original file, not ZIP)
    STAPLE_TARGET="$FILE_PATH"

    if xcrun stapler staple "$STAPLE_TARGET" 2>&1; then
        echo -e "${GREEN}✓ Ticket stapled successfully${NC}"
        echo ""

        # Verify stapling
        if xcrun stapler validate "$STAPLE_TARGET" 2>/dev/null; then
            echo -e "${GREEN}✓ Stapled ticket verified${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Stapling may have failed (this is sometimes OK for DMGs)${NC}"
    fi

    echo ""
    echo -e "${GREEN}✓ $FILE_NAME is now notarized and ready for distribution!${NC}"
    echo ""

    # Verify Gatekeeper will accept it
    echo -e "${YELLOW}Verifying Gatekeeper acceptance...${NC}"
    if spctl -a -t install "$FILE_PATH" 2>&1; then
        echo -e "${GREEN}✓ File will pass Gatekeeper on user Macs${NC}"
    else
        echo -e "${YELLOW}⚠ Gatekeeper check inconclusive${NC}"
    fi

else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}   Notarization Failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""

    # Extract submission ID if available
    SUBMISSION_ID=$(echo "$NOTARIZE_OUTPUT" | grep "id:" | head -1 | awk '{print $2}')

    if [ ! -z "$SUBMISSION_ID" ]; then
        echo "Submission ID: $SUBMISSION_ID"
        echo ""
        echo "To get detailed error information:"
        echo "  xcrun notarytool log $SUBMISSION_ID \\"
        echo "    --apple-id \"$APPLE_ID\" \\"
        echo "    --password \"[app-specific-password]\" \\"
        echo "    --team-id \"$TEAM_ID\""
        echo ""
    fi

    # Common issues
    echo "Common issues:"
    echo "  - App not signed with Developer ID certificate"
    echo "  - Hardened runtime not enabled (use --options runtime)"
    echo "  - Invalid entitlements"
    echo "  - Unsigned frameworks or libraries"
    echo ""
    echo "See DISTRIBUTION.md for troubleshooting"

    # Cleanup and exit
    if [ "$CLEANUP_ZIP" = true ]; then
        rm -f "$ZIP_NAME"
    fi
    exit 1
fi

# Cleanup temporary ZIP
if [ "$CLEANUP_ZIP" = true ]; then
    echo ""
    echo -e "${YELLOW}Cleaning up temporary ZIP...${NC}"
    rm -f "$ZIP_NAME"
    echo -e "${GREEN}✓ Cleanup complete${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Test the notarized file on a clean Mac"
echo "  2. Distribute to users!"
echo ""
