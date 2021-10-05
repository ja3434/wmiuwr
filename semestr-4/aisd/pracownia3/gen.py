import sys

mask = int(sys.argv[1])
print(3, 1, 1000000)

def f(m):
    t = [[0]*3]*3
    for i in range(3):
        for j in range(3):
            t[i][j] = (m >> (i*3 + j)) & 1
            print('x' if t[i][j] else '.', end='')
        print()

f(mask)