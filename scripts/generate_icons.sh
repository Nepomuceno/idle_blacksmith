#!/bin/bash
# Icon Generation Script for Idle Blacksmith
# Requires: ImageMagick (brew install imagemagick) or rsvg-convert (brew install librsvg)
#
# Run this script from the project root directory:
#   chmod +x scripts/generate_icons.sh
#   ./scripts/generate_icons.sh

set -e

SOURCE_ICON="icon.svg"
ICONS_DIR="assets/icons"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: $SOURCE_ICON not found in current directory"
    exit 1
fi

# Create icons directory
mkdir -p "$ICONS_DIR"

echo "Generating icons from $SOURCE_ICON..."

# Check for available conversion tool
if command -v rsvg-convert &> /dev/null; then
    CONVERTER="rsvg"
elif command -v magick &> /dev/null; then
    CONVERTER="imagemagick"
elif command -v convert &> /dev/null; then
    CONVERTER="convert"
else
    echo "Error: Neither ImageMagick nor librsvg found."
    echo "Install with: brew install imagemagick"
    echo "Or: brew install librsvg"
    exit 1
fi

convert_icon() {
    local size=$1
    local output=$2
    
    if [ "$CONVERTER" = "rsvg" ]; then
        rsvg-convert -w "$size" -h "$size" "$SOURCE_ICON" -o "$output"
    elif [ "$CONVERTER" = "imagemagick" ]; then
        magick "$SOURCE_ICON" -resize "${size}x${size}" "$output"
    else
        convert "$SOURCE_ICON" -resize "${size}x${size}" "$output"
    fi
}

# ============================================
# Android Icons
# ============================================
echo "Generating Android icons..."

# Main launcher icon
convert_icon 192 "$ICONS_DIR/android_main_192.png"

# Adaptive icon (foreground)
convert_icon 432 "$ICONS_DIR/android_adaptive_fg_432.png"

# Legacy icons for older Android versions
convert_icon 144 "$ICONS_DIR/android_144.png"
convert_icon 96 "$ICONS_DIR/android_96.png"
convert_icon 72 "$ICONS_DIR/android_72.png"
convert_icon 48 "$ICONS_DIR/android_48.png"
convert_icon 36 "$ICONS_DIR/android_36.png"

# ============================================
# iOS Icons
# ============================================
echo "Generating iOS icons..."

# App Store
convert_icon 1024 "$ICONS_DIR/ios_appstore_1024.png"

# iPhone
convert_icon 180 "$ICONS_DIR/ios_iphone_180.png"
convert_icon 120 "$ICONS_DIR/ios_iphone_120.png"

# iPhone Spotlight
convert_icon 120 "$ICONS_DIR/ios_iphone_spotlight_120.png"
convert_icon 80 "$ICONS_DIR/ios_iphone_spotlight_80.png"

# iPhone Settings
convert_icon 87 "$ICONS_DIR/ios_iphone_settings_87.png"
convert_icon 58 "$ICONS_DIR/ios_iphone_settings_58.png"

# iPhone Notification
convert_icon 60 "$ICONS_DIR/ios_iphone_notification_60.png"
convert_icon 40 "$ICONS_DIR/ios_iphone_notification_40.png"

# iPad
convert_icon 167 "$ICONS_DIR/ios_ipad_167.png"
convert_icon 152 "$ICONS_DIR/ios_ipad_152.png"
convert_icon 76 "$ICONS_DIR/ios_ipad_76.png"

# iPad Spotlight
convert_icon 80 "$ICONS_DIR/ios_ipad_spotlight_80.png"
convert_icon 40 "$ICONS_DIR/ios_ipad_spotlight_40.png"

# iPad Settings
convert_icon 58 "$ICONS_DIR/ios_ipad_settings_58.png"
convert_icon 29 "$ICONS_DIR/ios_ipad_settings_29.png"

# iPad Notification
convert_icon 40 "$ICONS_DIR/ios_ipad_notification_40.png"
convert_icon 20 "$ICONS_DIR/ios_ipad_notification_20.png"

# ============================================
# macOS Icons (for .icns generation)
# ============================================
echo "Generating macOS icons..."

convert_icon 1024 "$ICONS_DIR/macos_1024.png"
convert_icon 512 "$ICONS_DIR/macos_512.png"
convert_icon 256 "$ICONS_DIR/macos_256.png"
convert_icon 128 "$ICONS_DIR/macos_128.png"
convert_icon 64 "$ICONS_DIR/macos_64.png"
convert_icon 32 "$ICONS_DIR/macos_32.png"
convert_icon 16 "$ICONS_DIR/macos_16.png"

# Generate .icns file for macOS (requires macOS)
if command -v iconutil &> /dev/null; then
    echo "Generating macOS .icns file..."
    ICONSET_DIR="$ICONS_DIR/AppIcon.iconset"
    mkdir -p "$ICONSET_DIR"
    
    convert_icon 16 "$ICONSET_DIR/icon_16x16.png"
    convert_icon 32 "$ICONSET_DIR/icon_16x16@2x.png"
    convert_icon 32 "$ICONSET_DIR/icon_32x32.png"
    convert_icon 64 "$ICONSET_DIR/icon_32x32@2x.png"
    convert_icon 128 "$ICONSET_DIR/icon_128x128.png"
    convert_icon 256 "$ICONSET_DIR/icon_128x128@2x.png"
    convert_icon 256 "$ICONSET_DIR/icon_256x256.png"
    convert_icon 512 "$ICONSET_DIR/icon_256x256@2x.png"
    convert_icon 512 "$ICONSET_DIR/icon_512x512.png"
    convert_icon 1024 "$ICONSET_DIR/icon_512x512@2x.png"
    
    iconutil -c icns "$ICONSET_DIR" -o "$ICONS_DIR/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
    echo "Created: $ICONS_DIR/AppIcon.icns"
fi

# ============================================
# Windows Icons (.ico)
# ============================================
echo "Generating Windows icon..."

# Generate multiple sizes for .ico
convert_icon 256 "$ICONS_DIR/windows_256.png"
convert_icon 128 "$ICONS_DIR/windows_128.png"
convert_icon 64 "$ICONS_DIR/windows_64.png"
convert_icon 48 "$ICONS_DIR/windows_48.png"
convert_icon 32 "$ICONS_DIR/windows_32.png"
convert_icon 16 "$ICONS_DIR/windows_16.png"

# Create .ico file (requires ImageMagick)
if command -v magick &> /dev/null || command -v convert &> /dev/null; then
    if [ "$CONVERTER" = "imagemagick" ]; then
        magick "$ICONS_DIR/windows_256.png" "$ICONS_DIR/windows_128.png" \
               "$ICONS_DIR/windows_64.png" "$ICONS_DIR/windows_48.png" \
               "$ICONS_DIR/windows_32.png" "$ICONS_DIR/windows_16.png" \
               "$ICONS_DIR/AppIcon.ico"
    else
        convert "$ICONS_DIR/windows_256.png" "$ICONS_DIR/windows_128.png" \
                "$ICONS_DIR/windows_64.png" "$ICONS_DIR/windows_48.png" \
                "$ICONS_DIR/windows_32.png" "$ICONS_DIR/windows_16.png" \
                "$ICONS_DIR/AppIcon.ico"
    fi
    echo "Created: $ICONS_DIR/AppIcon.ico"
fi

echo ""
echo "=== Icon generation complete! ==="
echo ""
echo "Generated icons are in: $ICONS_DIR/"
echo ""
echo "Next steps:"
echo "1. Open your project in Godot Editor"
echo "2. Go to Project > Export"
echo "3. For each platform, set the icon paths to the generated icons"
echo ""
echo "Icon mapping:"
echo "  Windows:  $ICONS_DIR/AppIcon.ico"
echo "  macOS:    $ICONS_DIR/AppIcon.icns (or use res://icon.svg)"
echo "  Android:  $ICONS_DIR/android_main_192.png"
echo "  iOS:      Various icons in $ICONS_DIR/ios_*.png"
