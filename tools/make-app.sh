#!/bin/sh
# Build "Amber Protocol.app" -- a double-clickable launcher for the page.
#
# The launcher serves the file on a loopback port rather than opening it as a
# file:// URL, so the browser gives it a stable origin and therefore keeps your
# streak and scores in localStorage between runs.
#
#   ./tools/make-app.sh [destination]     # default: ~/Desktop
set -e

HERE=$(cd "$(dirname "$0")/.." && pwd)
DEST=${1:-$HOME/Desktop}
APP="$DEST/Amber Protocol.app"
PORT=8742

[ -d "$DEST" ] || { echo "no such directory: $DEST" >&2; exit 1; }

echo "building $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$HERE/amber-protocol.html" "$APP/Contents/Resources/index.html"
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

cat > "$APP/Contents/MacOS/launch" <<LAUNCH
#!/bin/sh
PORT=$PORT
LAUNCH
cat >> "$APP/Contents/MacOS/launch" <<'LAUNCH'
URL="http://127.0.0.1:$PORT/index.html"
RES=$(cd "$(dirname "$0")/../Resources" && pwd)

alive() { curl -fsS -o /dev/null --max-time 1 "$URL"; }

# An instance is already serving: just bring up another window and step aside.
if alive; then exec open "$URL"; fi

cd "$RES" || exit 1
python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SRV=$!
trap 'kill "$SRV" 2>/dev/null' EXIT INT TERM

n=0
while ! alive; do
  n=$((n + 1))
  [ "$n" -gt 40 ] && exit 1
  sleep 0.25
done

open "$URL"
wait "$SRV"      # the app stays running -- quit it to stop the server
LAUNCH

chmod +x "$APP/Contents/MacOS/launch"
touch "$APP"     # nudge Finder to pick up the icon
echo "done -> $APP"
