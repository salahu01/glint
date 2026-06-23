#!/bin/bash
# Builds, Developer ID-signs, notarizes and staples Glint.app so it opens with
# no Gatekeeper warning. REQUIRES a paid Apple Developer account.
#
# One-time setup:
#   1. In Xcode/Keychain, install a "Developer ID Application" certificate.
#   2. Store notarization credentials in a keychain profile:
#        xcrun notarytool store-credentials glint-notary \
#          --apple-id "you@example.com" --team-id "ABCDE12345" \
#          --password "app-specific-password"
#
# Usage:  SIGN_ID="Developer ID Application: Your Name (ABCDE12345)" ./notarize.sh
set -euo pipefail

APP_NAME="Glint"
BUNDLE="${APP_NAME}.app"
ZIP="${APP_NAME}-notarize.zip"
PROFILE="${NOTARY_PROFILE:-glint-notary}"

: "${SIGN_ID:?Set SIGN_ID to your 'Developer ID Application: …' identity}"

echo "==> Building release bundle..."
./make-app.sh

echo "==> Signing with hardened runtime..."
codesign --force --deep --options runtime --timestamp \
    --sign "${SIGN_ID}" "${BUNDLE}"

echo "==> Zipping for submission..."
rm -f "${ZIP}"
ditto -c -k --keepParent "${BUNDLE}" "${ZIP}"

echo "==> Submitting to Apple notary service (waits for result)..."
xcrun notarytool submit "${ZIP}" --keychain-profile "${PROFILE}" --wait

echo "==> Stapling ticket..."
xcrun stapler staple "${BUNDLE}"
xcrun stapler validate "${BUNDLE}"

rm -f "${ZIP}"
echo "==> Done. ${BUNDLE} is notarized and ready to distribute."
