#!/bin/bash

make brut
make rozw3


for i in {1..10000}
do
    echo $i
    python3 gen.py $i $1 > test.in
    ./rozw3 < test.in > wa.out
    ./brut < test.in > test.out

    if diff -w test.out wa.out
    then
        echo ok
    else
        echo nieok
        break
    fi
done
