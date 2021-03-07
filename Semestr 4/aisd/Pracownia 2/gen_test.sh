#!/bin/bash

mkdir -p tests
cp gen.py tests/
cd tests

python3 gen.py 1 5 20 > t1.in
python3 gen.py 2 10 100 > t2.in
python3 gen.py 3 20 200 > t3.in
python3 gen.py 4 40 600 > t4.in
python3 gen.py 5 80 5000 > t5.in
python3 gen.py 6 160 10000 > t6.in
python3 gen.py 7 320 10000 > t7.in
python3 gen.py 8 640 20000 > t8.in
python3 gen.py 9 1280 20000 > t9.in
python3 gen.py 10 2000 2000 > t10.in
python3 gen.py 11 2000 20000 > t11.in
python3 gen.py 12 2000 200000 > t12.in
python3 gen.py 13 2000 1000000 > t13.in
python3 gen.py 14 2000 1000000 > t14.in
python3 gen.py 15 2000 1000000 > t15.in


rm gen.py
