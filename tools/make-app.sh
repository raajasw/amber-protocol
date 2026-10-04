#!/bin/sh
# Build "Amber Protocol.app" -- a double-clickable launcher for the page.
#
# The app holds its own copy of the HTML, so re-run this after editing the page.
#
#   ./tools/make-app.sh [destination]     # default: ~/Desktop
set -e

HERE=$(cd "$(dirname "$0")/.." && pwd)
DEST=${1:-$HOME/Desktop}
APP="$DEST/Amber Protocol.app"

[ -d "$DEST" ] || { echo "no such directory: $DEST" >&2; exit 1; }

echo "building $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$HERE/index.html" "$APP/Contents/Resources/index.html"
python3 "$HERE/tools/make-icon.py" "$APP/Contents/Resources/icon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Amber Protocol</string>
  <key>CFBundleDisplayName</key><string>Amber Protocol</string>
  <key>CFBundleExecutable</key><string>launch</string>
  <key>CFBundleIdentifier</key><string>local.amberprotocol.launcher</string>
  <key>CFBundleIconFile</key><string>icon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

cat > "$APP/Contents/MacOS/launch" <<'LAUNCH'
#!/bin/sh
# Hand the page to the default browser and get out of the way.
#
# Deliberately no local web server: serving it would give localStorage a
# stable origin, but it also makes macOS prompt about python3 accepting
# network connections, and it leaves a process running. A file:// hand-off
# has no dependencies, no prompt, and nothing to quit. Absolute path to
# open(1) because a Finder-launched app gets a minimal PATH.
RES=$(cd "$(dirname "$0")/../Resources" && pwd) || exit 1
exec /usr/bin/open "$RES/index.html"
LAUNCH

chmod +x "$APP/Contents/MacOS/launch"
touch "$APP"     # nudge Finder to pick up the icon
echo "done -> $APP"
