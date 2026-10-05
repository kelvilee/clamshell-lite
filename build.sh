#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release
APP=build/ClamshellLite.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/ClamshellLite" "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
mkdir -p "$APP/Contents/Resources" build/AppIcon.iconset
swift Icon/make-icon.swift build/icon-1024.png
for px in 16 32 128 256 512; do
    sips -z $px $px build/icon-1024.png --out build/AppIcon.iconset/icon_${px}x${px}.png >/dev/null
    sips -z $((px * 2)) $((px * 2)) build/icon-1024.png --out build/AppIcon.iconset/icon_${px}x${px}@2x.png >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP"
echo "Built $APP"
