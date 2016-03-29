#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"

for PROJECT in $PROJECTS; do
  $MAKE -C "$OSDIR/$PROJECT" clean
done
