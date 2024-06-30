#!/bin/bash
set -e

info() {
    local GREEN="\033[0;32m"
    local NO_COLOR="\033[0m" # No color (reset to default)
    echo -e "${GREEN}INFO: $*${NO_COLOR}"
}

APPDIR="$1"

if [ -z "$2" ]; then
    #DMG="$(basename ${APPDIR%.*}).dmg"
    DMG="${APPDIR%.*}.dmg"
else
    DMG="$2"
fi


LAUNCHER=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" $APPDIR/Contents/Info.plist)
APP_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" $APPDIR/Contents/Info.plist)

ARCH=$(file $APPDIR/Contents/Libraries/julia/bin/julia | grep -o 'x86_64\|arm64' | uniq)


info "Forming launcher"

[ ! -f "$APPDIR/Contents/MacOS/main" ] && mv "$APPDIR/Contents/MacOS/$LAUNCHER" "$APPDIR/Contents/MacOS/main"

gcc -arch $ARCH -o "$APPDIR/Contents/MacOS/$LAUNCHER" "$APPDIR/Contents/Resources/launcher.c"

info "Precompiling"
"$APPDIR/Contents/MacOS/precompile"

info "Codesigning"

codesign --force --sign "JanisErdmanis" "$APPDIR/Contents/Libraries/julia/bin/julia"
codesign --force --sign "JanisErdmanis" "$APPDIR/Contents/Libraries/julia/libexec/julia/lld"
codesign --force --sign "JanisErdmanis" "$APPDIR/Contents/Libraries/julia/libexec/julia/dsymutil"

codesign --entitlements "$APPDIR/Contents/Resources/Entitlements.plist" --force --sign "JanisErdmanis" --deep "$APPDIR"

info "Bundling app into dmg"

TMPAPP="$TMPDIR/$APP_NAME.app"

cleanup() {
    [ -d "$TMPAPP" ] && mv "$TMPAPP" "$APPDIR" 
}

mv "$APPDIR" "$TMPAPP"
dmgbuild -s "$TMPAPP/Contents/Resources/dmg_settings.py" -D app="$TMPAPP" "$APP_NAME Installer" "$DMG"
cleanup

codesign --sign "JanisErdmanis" -v "$DMG"
