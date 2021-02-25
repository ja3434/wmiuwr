import random
import sys

random.seed(sys.argv[1])

t = []
n = int(sys.argv[2])
t = [1]
print(n)

fir i in range(n):
  ojc = random.choice(t)
  print(i, ojc)
  t.append(i)