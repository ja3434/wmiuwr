from random import randint, seed
import sys

if (len(sys.argv) < 4):
    print("usage: python3 gen.py seed n sum")
    exit()

seed(sys.argv[1])

n, sum = map(int, sys.argv[2:4])
if n > sum:
    print("N musi być mniejsze równe od sum.")
    exit()

t = [1 for i in range(n)]

for i in range(sum - n):
    idx = randint(0, n - 1)
    t[idx] += 1

print(n)
for i in t:
    print(i, end=' ')
print()
