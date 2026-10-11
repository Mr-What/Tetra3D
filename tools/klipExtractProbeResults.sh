#!/usr/bin/sh -x
grep 'Result: at .*estimate' $1 | sed -E -e 's/^Result: at//' -e 's/estimate contact at z=/,/'

