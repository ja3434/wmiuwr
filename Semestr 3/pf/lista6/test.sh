make wzo
make brut
for i in {1..1000}
do  python3 test.py $i > test.in
  ./wzo <test.in >wa.out
  ./brut <test.in > t.out
  if diff -w wa.out t.out
  then
  echo ok
  else
  echo "nieok"
  break
  fi
done