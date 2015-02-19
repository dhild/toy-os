#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"
"$( dirname "${BASH_SOURCE[0]}" )/disk-mount.sh"

for PROJECT in $SYSTEM_HEADER_PROJECTS; do
  DESTDIR="$SYSROOT" $MAKE -C "$OSDIR/$PROJECT" install-headers
done
