def fun(r):
  for i in range(r):
    n = 2**i
    while n > 10:
      n //= 10
    print(f"{i}: {2**i} {n} {'<-- ' if n == 1 else ''}")

