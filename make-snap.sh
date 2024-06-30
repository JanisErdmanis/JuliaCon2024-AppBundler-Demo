#!/bin/bash
set -e

info() {
    local GREEN="\033[0;32m"
    local NO_COLOR="\033[0m" # No color (reset to default)
    echo -e "${GREEN}INFO: $*${NO_COLOR}"
}

APPDIR="$1"

if [ -z "$2" ]; then
    SNAP="${APPDIR%.*}.snap"
else
    SNAP="$2"
fi

info "Precompiling"

$APPDIR/bin/precompile

info "Bundling the SNAP"
rm -f $SNAP
mksquashfs $APPDIR $SNAP -noappend -comp xz
