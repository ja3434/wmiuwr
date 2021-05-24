import random
import sys

random.seed(sys.argv[1])

n = int(sys.argv[2])
maxcoord = 1000


print(n)
for i in range(n):
  ty = random.randint(0, 3)
  a, b = 0, 0
  y1, y2 = 0, 0
  if ty == 0:
    a = random.randint(0, maxcoord)
    b = random.randint(a+1, maxcoord + 1)
    y1 = random.randint(0, maxcoord)
    y2 = y1
  if ty == 1:
    y1 = random.randint(0, maxcoord)
    y2 = random.randint(a+1, maxcoord + 1)
    a = random.randint(0, maxcoord)
    b = a
  if ty == 2:
    a = random.randint(0, maxcoord)
    b = random.randint(0, maxcoord)
    x = random.randint(1, maxcoord)
    y1 = b
    b = a + x
    y2 = y1 + x
  if ty == 3:
    a = random.randint(0, maxcoord)
    b = random.randint(0, maxcoord)
    x = random.randint(1, maxcoord)
    y1 = b
    b = a + x
    y2 = y1 - x

  print(a, y1, b, y2)
