#!/bin/bash

# Generate SignPaw logos and favicons using ImageMagick
# Alternative to Node.js script when sharp has build issues

OUT_DIR="public"
SVG_SOURCE="$OUT_DIR/logo.svg"

if [ ! -f "$SVG_SOURCE" ]; then
  echo "Error: $SVG_SOURCE not found!"
  exit 1
fi

echo "Generating SignPaw logos and favicons from $SVG_SOURCE..."

# Use magick (ImageMagick v7) or convert (ImageMagick v6)
MAGICK_CMD=$(command -v magick || command -v convert || echo "convert")

# Generate favicon.ico (requires multiple sizes)
$MAGICK_CMD "$SVG_SOURCE" -resize 16x16 "$OUT_DIR/favicon-16x16.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 32x32 "$OUT_DIR/favicon-32x32.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 48x48 "$OUT_DIR/temp-48.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 64x64 "$OUT_DIR/temp-64.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 128x128 "$OUT_DIR/temp-128.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 256x256 "$OUT_DIR/temp-256.png"

# Create favicon.ico from multiple sizes
$MAGICK_CMD "$OUT_DIR/favicon-16x16.png" "$OUT_DIR/favicon-32x32.png" "$OUT_DIR/temp-48.png" "$OUT_DIR/temp-64.png" "$OUT_DIR/temp-128.png" "$OUT_DIR/temp-256.png" "$OUT_DIR/favicon.ico"
rm "$OUT_DIR/temp-*.png"
echo "✓ Generated $OUT_DIR/favicon.ico"

# Generate standard favicons
$MAGICK_CMD "$SVG_SOURCE" -resize 96x96 "$OUT_DIR/favicon-96x96.png"
echo "✓ Generated $OUT_DIR/favicon-96x96.png"

# Generate Apple touch icons
$MAGICK_CMD "$SVG_SOURCE" -resize 180x180 "$OUT_DIR/apple-touch-icon.png"
echo "✓ Generated $OUT_DIR/apple-touch-icon.png"

# Generate Android Chrome icons
$MAGICK_CMD "$SVG_SOURCE" -resize 192x192 "$OUT_DIR/android-chrome-192x192.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 512x512 "$OUT_DIR/android-chrome-512x512.png"
echo "✓ Generated Android Chrome icons"

# Generate MS Tile
$MAGICK_CMD "$SVG_SOURCE" -resize 150x150 "$OUT_DIR/mstile-150x150.png"
echo "✓ Generated $OUT_DIR/mstile-150x150.png"

# Generate high-resolution logos for navbar
$MAGICK_CMD "$SVG_SOURCE" -resize 40x40 "$OUT_DIR/logo-40x40.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 80x80 "$OUT_DIR/logo-80x80.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 160x160 "$OUT_DIR/logo-160x160.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 320x320 "$OUT_DIR/logo-320x320.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 640x640 "$OUT_DIR/logo-640x640.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 1280x1280 "$OUT_DIR/logo-1280x1280.png"
$MAGICK_CMD "$SVG_SOURCE" -resize 2560x2560 "$OUT_DIR/logo-2560x2560.png"
echo "✓ Generated high-resolution logos"

# Generate web manifest
cat > "$OUT_DIR/site.webmanifest" << 'EOF'
{
  "name": "SignPaw",
  "short_name": "SignPaw",
  "description": "Sign with a touch of a paw - Free, secure, and open-source e-signature platform",
  "icons": [
    {
      "src": "/android-chrome-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/android-chrome-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "theme_color": "#5B5FC7",
  "background_color": "#F8FAFC",
  "display": "standalone"
}
EOF
echo "✓ Generated $OUT_DIR/site.webmanifest"

echo ""
echo "✅ All SignPaw logos and favicons generated successfully!"
echo "   Motto: 'Sign with a touch of a paw'"

