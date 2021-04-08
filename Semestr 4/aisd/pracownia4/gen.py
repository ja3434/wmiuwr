from random import randint, seed, choice
import sys


seed(sys.argv[1])
n = int(sys.argv[2])
l = 0
print(n)


for i in range(n):
    c = choice('ISD')
    if l == 0:
        c = 'I'

    if c == 'D':
        print(c, randint(1, l))
        l -= 1
    elif c == 'I':
        print(c, randint(0, l), randint(-10, 10))
        l += 1
    else:
        a = randint(1, l)
        print(c, a, randint(a, l))