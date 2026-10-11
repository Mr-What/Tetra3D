#!/usr/bin/sh -x
grep 'probe:.*bed will contact at' "$1" | \
    sed -E -e 's/probe: at\s+//' \
    -e 's/ bed will contact at z=/,/'
