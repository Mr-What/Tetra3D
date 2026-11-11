#!/usr/bin/sh -x
grep '^DIMPLE ' $1 | grep -E 'probe at estimated vertex| neighbor ' | sed -E \
    -e 's/DIMPLE *//' \
    -e 's/ *probe.*vertex */,/' \
    -e 's/ *neighbor */,/' \
    -e 's/: */,/' \
    -e 's/\s+//g'
