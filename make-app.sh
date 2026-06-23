#!/bin/bash
# Builds FloatingClock.app — a double-clickable macOS app bundle.
# Run: ./make-app.sh   then open FloatingClock.app (or drag to /Applications).
set -euo pipefail

APP_NAME="FloatingClock"
BUNDLE="${APP_NAME}.app"
BIN_PATH=".build/release/${APP_NAME}"

echo "==> Building release binary..."
swift build -c release

echo "==> Assembling ${BUNDLE}..."
rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}/Contents/MacOS"
mkdir -p "${BUNDLE}/Contents/Resources"
cp "${BIN_PATH}" "${BUNDLE}/Contents/MacOS/${APP_NAME}"

cat > "${BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>     <string>Floating Clock</string>
    <key>CFBundleIdentifier</key>      <string>com.fegno.floatingclock</string>
    <key>CFBundleVersion</key>         <string>1.0</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleExecutable</key>      <string>${APP_NAME}</string>
    <key>LSMinimumSystemVersion</key>  <string>13.0</string>
    <!-- Agent app: no Dock icon, lives in the menu bar / floats on screen. -->
    <key>LSUIElement</key>             <true/>
    <key>NSHighResolutionCapable</key> <true/>
</dict>
</plist>
PLIST

# Ad-hoc code signature so Gatekeeper/audio engine are happy on the local machine.
echo "==> Code signing (ad-hoc)..."
codesign --force --deep --sign - "${BUNDLE}" >/dev/null 2>&1 || true

echo "==> Done: ${BUNDLE}"
echo "    Launch with:  open ${BUNDLE}"
