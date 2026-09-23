#!/bin/sh
# Runs on the build machine after `npx cap add ios`: adds the push entitlement and background mode Capacitor doesn't add by itself.
set -e
cd "$(dirname "$0")"
ENT=ios/App/App/App.entitlements
cat > "$ENT" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>aps-environment</key><string>production</string></dict></plist>
PLIST
# point both build configurations at the entitlements file
PBX=ios/App/App.xcodeproj/project.pbxproj
grep -q "CODE_SIGN_ENTITLEMENTS" "$PBX" || sed -i.bak 's/PRODUCT_BUNDLE_IDENTIFIER = /CODE_SIGN_ENTITLEMENTS = App\/App.entitlements; PRODUCT_BUNDLE_IDENTIFIER = /g' "$PBX"
# background mode: remote notifications
PLIST=ios/App/App/Info.plist
/usr/libexec/PlistBuddy -c "Add :UIBackgroundModes array" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIBackgroundModes:0 string remote-notification" "$PLIST" 2>/dev/null || true
# display name
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Plex Director" "$PLIST" 2>/dev/null || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string Plex Director" "$PLIST"
echo "iOS project prepared"
