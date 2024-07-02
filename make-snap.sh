#!/bin/bash
set -e

info() {
    local GREEN="\033[0;32m"
    local NO_COLOR="\033[0m" # No color (reset to default)
    echo -e "${GREEN}INFO: $*${NO_COLOR}"
}

APPDIR="$1"
TEMP_DIR=""

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        info "Cleaning up temporary directory"
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

if [ "${APPDIR##*.}" = "snap" ]; then
    info "Input is a snap file, unsquashing..."
    TEMP_DIR=$(mktemp -d)
    unsquashfs -d "$TEMP_DIR" "$APPDIR"
    APPDIR="$TEMP_DIR"
fi

if [ -z "$2" ]; then
    SNAP="${1%.*}.snap"
else
    SNAP="$2"
fi

info "Precompiling"

$APPDIR/bin/precompile

info "Bundling the SNAP"
rm -f "$SNAP"
mksquashfs "$APPDIR" "$SNAP" -noappend -comp xz
