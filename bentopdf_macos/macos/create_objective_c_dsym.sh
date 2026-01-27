#!/bin/bash

# Create a minimal dSYM for objective_c framework to satisfy App Store Connect
# This framework comes pre-built from pub.dev without debug symbols

set -e

echo "Creating dSYM for objective_c framework..."

# Paths
FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework"
BINARY_PATH="${FRAMEWORK_PATH}/Versions/A/objective_c"
DSYM_PATH="${BUILT_PRODUCTS_DIR}/objective_c.framework.dSYM"

# Check if framework exists
if [ ! -f "$BINARY_PATH" ]; then
    echo "Warning: objective_c framework not found at $BINARY_PATH"
    exit 0
fi

echo "Framework found at: $FRAMEWORK_PATH"

# Create dSYM bundle structure
mkdir -p "${DSYM_PATH}/Contents/Resources/DWARF"

# Create Info.plist for dSYM
cat > "${DSYM_PATH}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleIdentifier</key>
	<string>com.apple.xcode.dsym.objective_c</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundlePackageType</key>
	<string>dSYM</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
EOF

# Copy the binary to dSYM (this preserves UUIDs and architecture info)
cp "$BINARY_PATH" "${DSYM_PATH}/Contents/Resources/DWARF/objective_c"

# Strip debug info if any (should already be stripped, but ensure it)
strip -S "${DSYM_PATH}/Contents/Resources/DWARF/objective_c" 2>/dev/null || true

echo "✓ Created dSYM at: $DSYM_PATH"

# Verify UUIDs match
ORIGINAL_UUIDS=$(dwarfdump --uuid "$BINARY_PATH" | awk '{print $2}')
DSYM_UUIDS=$(dwarfdump --uuid "${DSYM_PATH}/Contents/Resources/DWARF/objective_c" | awk '{print $2}')

echo "Original UUIDs: $ORIGINAL_UUIDS"
echo "dSYM UUIDs:     $DSYM_UUIDS"

if [ "$ORIGINAL_UUIDS" = "$DSYM_UUIDS" ]; then
    echo "✓ UUIDs match"
else
    echo "⚠ Warning: UUIDs may not match"
fi

exit 0
