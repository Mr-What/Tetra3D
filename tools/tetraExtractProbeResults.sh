#!/usr/bin/sh -x
grep  '^PROBE RESULT ' "$1" | sed -E -e "s/PROBE RESULT //" -e s/:/,/

# klipper Result lines have probe offset in them,
# tetra PROBE RESULT line have removed offset, showing toolhead position at trigger
#grep '^PROBE RESULT ' $1 | Result: at .*estimate' $1 | sed -E -e 's/^Result: at//' -e 's/estimate contact at z=/,/'

