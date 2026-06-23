#!/bin/bash
# Generates Assets/Glint.icns from Assets/make-icon.swift.
set -euo pipefail

cd "$(dirname "$0")"
MASTER="Assets/icon_1024.png"
ICONSET="Assets/Glint.iconset"
ICNS="Assets/Glint.icns"

echo "==> Rendering master PNG..."
swift Assets/make-icon.swift "${MASTER}"

echo "==> Building iconset..."
rm -rf "${ICONSET}"
mkdir -p "${ICONSET}"
for s in 16 32 128 256 512; do
    sips -z $s $s        "${MASTER}" --out "${ICONSET}/icon_${s}x${s}.png"       >/dev/null
    sips -z $((s*2)) $((s*2)) "${MASTER}" --out "${ICONSET}/icon_${s}x${s}@2x.png" >/dev/null
done

echo "==> Packing .icns..."
iconutil -c icns "${ICONSET}" -o "${ICNS}"
rm -rf "${ICONSET}" "${MASTER}"
echo "==> Done: ${ICNS}"
