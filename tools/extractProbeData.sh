#!/usr/bin/sh -x
grep 'Result: at .*estimate' $1 | sed 's/^Result: at//' | sed 's/estimate contact at z=/,/'

