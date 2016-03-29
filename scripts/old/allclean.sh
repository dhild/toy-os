#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"

"$( dirname "${BASH_SOURCE[0]}" )/disk-unmount.sh"
rm -rfv "$DISKIMG" "$SYSROOT"

"$( dirname "${BASH_SOURCE[0]}" )/clean.sh"

