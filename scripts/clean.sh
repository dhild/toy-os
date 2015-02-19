#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"

"$( dirname "${BASH_SOURCE[0]}" )/disk-unmount.sh"
rm -rfv "$DISKIMG" "$SYSROOT"

for PROJECT in $PROJECTS; do
  $MAKE -C "$OSDIR/$PROJECT" clean
done

