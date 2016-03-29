#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"
"$( dirname "${BASH_SOURCE[0]}" )/headers.sh"

for PROJECT in $PROJECTS; do
  DESTDIR="$SYSROOT" $MAKE -C "$OSDIR/$PROJECT" install
done
