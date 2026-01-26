#!/bin/bash

# SitiPDF Release Build Script
# Builds a signed, release-ready version of SitiPDF for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   SitiPDF Release Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get version from pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
echo "Building version: $VERSION"
echo ""

# Parse command line arguments
SIGN_IDENTITY=""
SKIP_SIGNING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --sign)
            SIGN_IDENTITY="$2"
            shift 2
            ;;
        --no-sign)
            SKIP_SIGNING=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--sign \"Developer ID Application: Name\"] [--no-sign]"
            exit 1
            ;;
    esac
done

# Check for signing certificate if not skipping
if [ "$SKIP_SIGNING" = false ]; then
    echo -e "${YELLOW}Checking for code signing certificates...${NC}"

    if [ -z "$SIGN_IDENTITY" ]; then
        # Try to find Developer ID certificate
        CERT_LIST=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" || true)

        if [ -z "$CERT_LIST" ]; then
            echo -e "${YELLOW}⚠ No Developer ID Application certificate found${NC}"
            echo ""
            echo "Available certificates:"
            security find-identity -v -p codesigning
            echo ""
            echo -e "${YELLOW}Building with ad-hoc signing (for local testing only)${NC}"
            echo "For distribution, you need a Developer ID Application certificate"
            echo "See DISTRIBUTION.md for details"
            SKIP_SIGNING=true
        else
            # Extract the first Developer ID certificate
            SIGN_IDENTITY=$(echo "$CERT_LIST" | head -1 | sed 's/.*"\(.*\)".*/\1/')
            echo -e "${GREEN}✓ Found certificate: $SIGN_IDENTITY${NC}"
        fi
    else
        echo "Using provided identity: $SIGN_IDENTITY"

        # Verify the identity exists
        if ! security find-identity -v -p codesigning | grep -q "$SIGN_IDENTITY"; then
            echo -e "${RED}Error: Certificate not found: $SIGN_IDENTITY${NC}"
            echo ""
            echo "Available certificates:"
            security find-identity -v -p codesigning
            exit 1
        fi
        echo -e "${GREEN}✓ Certificate verified${NC}"
    fi
    echo ""
fi

# Clean previous builds
echo -e "${YELLOW}Step 1: Cleaning previous builds...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}Step 2: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies retrieved${NC}"
echo ""

# Build release version
echo -e "${YELLOW}Step 3: Building release version...${NC}"
flutter build macos --release
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

APP_PATH="build/macos/Build/Products/Release/SitiPDF.app"

# Sign the app if we have a certificate
if [ "$SKIP_SIGNING" = false ] && [ ! -z "$SIGN_IDENTITY" ]; then
    echo -e "${YELLOW}Step 4: Signing application...${NC}"

    # Sign with hardened runtime for notarization
    codesign --force --deep \
        --options runtime \
        --sign "$SIGN_IDENTITY" \
        "$APP_PATH"

    echo -e "${GREEN}✓ Application signed${NC}"
    echo ""

    # Verify signature
    echo -e "${YELLOW}Step 5: Verifying signature...${NC}"
    if codesign --verify --verbose "$APP_PATH"; then
        echo -e "${GREEN}✓ Signature verified${NC}"

        # Display signature details
        echo ""
        echo "Signature details:"
        codesign -dv --verbose=2 "$APP_PATH" 2>&1 | grep "Authority\|Identifier\|TeamIdentifier" || true
    else
        echo -e "${RED}✗ Signature verification failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Step 4: Skipping code signing (ad-hoc signing)${NC}"
    echo "⚠ App will only run on this Mac or Macs with Developer Mode enabled"
fi
echo ""

# Get app size
APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Version: $VERSION"
echo "Output: $APP_PATH"
echo "Size: $APP_SIZE"
echo ""

if [ "$SKIP_SIGNING" = false ] && [ ! -z "$SIGN_IDENTITY" ]; then
    echo -e "${GREEN}✓ App is signed and ready for notarization${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Test the app locally"
    echo "  2. Create DMG installer: ./scripts/create_dmg.sh"
    echo "  3. Notarize with Apple (see DISTRIBUTION.md)"
else
    echo -e "${YELLOW}⚠ App is built but not signed for distribution${NC}"
    echo ""
    echo "For testing only. To distribute:"
    echo "  1. Get a Developer ID Application certificate"
    echo "  2. Rebuild with: ./scripts/build_release.sh --sign \"Developer ID Application: Your Name\""
    echo "  3. Create DMG installer: ./scripts/create_dmg.sh"
    echo "  4. Notarize with Apple (see DISTRIBUTION.md)"
fi
echo ""
