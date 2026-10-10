#!/usr/bin/sh -x
grep '^DIMPLE ' $1 | grep -E 'probe at estimated vertex| neighbor ' | sed -E \
    -e 's/DIMPLE *//' \
    -e 's/ *probe.*vertex */ /' \
    -e 's/ *neighbor *//' \
    -e 's/ : */ /' \
    -e 's/:/,/' \
    -e 's/, */,/g' \
    -e 's/ +/,/' 




#grep '^DIMPLE ' $1 | sed 's/DIMPLE *//' | grep -E 'probe at estimated vertex| neighbor ' | sed 's/ *probe.*vertex */ /' | sed 's/ *neighbor *//' | sed 's/ : */ /' | sed 's/:/,/' | sed 's/, */,/g' | sed -E 's/ +/,/' 
# no.  many probes in file. this removes all lines before pattern : sed -n '/probe at estimated vertex/,$p'
