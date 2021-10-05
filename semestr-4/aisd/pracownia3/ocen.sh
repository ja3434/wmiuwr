#!/bin/bash

make rozw
make check
for i in {0..1023}
do
    python3 gen.py $i > t.in
    ./rozw < t.in > wa.out
    ./check < t.in > t.out
    if diff -w wa.out t.out
    then
        echo $i
        echo ok
    else
        echo nieok
        break
    fi
done