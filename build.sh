#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release
APP=build/ClamshellLite.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/ClamshellLite" "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
codesign --force --sign - "$APP"
echo "Built $APP"
