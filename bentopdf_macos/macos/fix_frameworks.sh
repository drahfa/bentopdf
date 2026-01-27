#!/bin/bash

# Fix framework structure for App Store validation
# This script ensures frameworks have the correct symbolic link structure

set -e

echo "Fixing framework structures for App Store compliance..."

# Find all framework bundles in the app
FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

if [ -d "$FRAMEWORKS_DIR" ]; then
    echo "Scanning frameworks in: $FRAMEWORKS_DIR"

    # Process each framework
    for FRAMEWORK in "$FRAMEWORKS_DIR"/*.framework; do
        if [ -d "$FRAMEWORK" ]; then
            FRAMEWORK_NAME=$(basename "$FRAMEWORK" .framework)
            echo "Processing framework: $FRAMEWORK_NAME"

            # Check if Versions directory exists
            VERSIONS_DIR="$FRAMEWORK/Versions"
            if [ ! -d "$VERSIONS_DIR" ]; then
                echo "  Creating Versions directory structure..."
                mkdir -p "$VERSIONS_DIR/A"

                # Move framework contents to Versions/A
                for ITEM in "$FRAMEWORK"/*; do
                    ITEM_NAME=$(basename "$ITEM")
                    if [ "$ITEM_NAME" != "Versions" ]; then
                        mv "$ITEM" "$VERSIONS_DIR/A/"
                    fi
                done

                # Create Current symlink
                ln -sf "A" "$VERSIONS_DIR/Current"

                # Create top-level symlinks
                ln -sf "Versions/Current/$FRAMEWORK_NAME" "$FRAMEWORK/$FRAMEWORK_NAME"

                if [ -d "$VERSIONS_DIR/A/Resources" ]; then
                    ln -sf "Versions/Current/Resources" "$FRAMEWORK/Resources"
                fi

                if [ -d "$VERSIONS_DIR/A/Headers" ]; then
                    ln -sf "Versions/Current/Headers" "$FRAMEWORK/Headers"
                fi

                if [ -d "$VERSIONS_DIR/A/Modules" ]; then
                    ln -sf "Versions/Current/Modules" "$FRAMEWORK/Modules"
                fi

                echo "  ✓ Framework structure created"
            else
                echo "  Versions directory exists, verifying symlinks..."

                # Ensure Current symlink exists and points to A
                if [ ! -L "$VERSIONS_DIR/Current" ]; then
                    echo "    Creating Current symlink..."
                    ln -sf "A" "$VERSIONS_DIR/Current"
                fi

                # Fix top-level symlinks to go through Current
                # Remove existing symlinks/files and recreate them correctly

                # Fix framework binary symlink
                if [ -e "$FRAMEWORK/$FRAMEWORK_NAME" ]; then
                    rm -f "$FRAMEWORK/$FRAMEWORK_NAME"
                fi
                ln -sf "Versions/Current/$FRAMEWORK_NAME" "$FRAMEWORK/$FRAMEWORK_NAME"

                # Fix Resources symlink - MUST go through Current, not directly to A
                if [ -d "$VERSIONS_DIR/A/Resources" ]; then
                    if [ -e "$FRAMEWORK/Resources" ]; then
                        rm -f "$FRAMEWORK/Resources"
                    fi
                    ln -sf "Versions/Current/Resources" "$FRAMEWORK/Resources"
                    echo "    ✓ Fixed Resources symlink"
                fi

                # Fix Headers symlink
                if [ -d "$VERSIONS_DIR/A/Headers" ]; then
                    if [ -e "$FRAMEWORK/Headers" ]; then
                        rm -f "$FRAMEWORK/Headers"
                    fi
                    ln -sf "Versions/Current/Headers" "$FRAMEWORK/Headers"
                fi

                # Fix Modules symlink
                if [ -d "$VERSIONS_DIR/A/Modules" ]; then
                    if [ -e "$FRAMEWORK/Modules" ]; then
                        rm -f "$FRAMEWORK/Modules"
                    fi
                    ln -sf "Versions/Current/Modules" "$FRAMEWORK/Modules"
                fi

                echo "  ✓ Framework symlinks verified and fixed"
            fi
        fi
    done

    echo "✓ All frameworks processed"
else
    echo "No frameworks directory found at: $FRAMEWORKS_DIR"
fi

exit 0
