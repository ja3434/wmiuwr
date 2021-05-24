def next_permutation(a):
  """Generate the lexicographically next permutation inplace.

  https://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order
  Return false if there is no next permutation.
  """
  # Find the largest index i such that a[i] < a[i + 1]. If no such
  # index exists, the permutation is the last permutation
  for i in reversed(range(len(a) - 1)):
      if a[i] < a[i + 1]:
          break  # found
  else:  # no break: not found
      return False  # no next permutation

  # Find the largest index j greater than i such that a[i] < a[j]
  j = next(j for j in reversed(range(i + 1, len(a))) if a[i] < a[j])

  # Swap the value of a[i] with that of a[j]
  a[i], a[j] = a[j], a[i]

  # Reverse sequence from a[i + 1] up to and including the final element a[n]
  a[i + 1:] = reversed(a[i + 1:])
  return True

def perm_to_str(a):
  return ''.join(map(str, a))

def str_to_perm(s):
  return [int(c) for c in s]

t = [0,1,2,3]
perm_to_idx = dict()

def bbin(x):
  return bin(x)[2:]

cnt = 23
while True:
  perm_to_idx[perm_to_str(t)] = cnt
  cnt -= 1
  if not next_permutation(t):
    break

for p in perm_to_idx.keys():
  for i in range(4):
    t = str_to_perm(p)
    for j in range(4):
      if t[j] > t[i]:
        t[j] -= 1
    t[i] = 3
    print(p, 'x', i, '->', perm_to_str(t), ':\t', bbin(perm_to_idx[p]), '\t', bbin(i), '\t', bbin(perm_to_idx[perm_to_str(t)]), end='\t')
    print(perm_to_idx[p], '\t', i, '\t', perm_to_idx[perm_to_str(t)])

print('\n-----\n')


for p in perm_to_idx.keys():
  for i in range(4):
    t = str_to_perm(p)
    for j in range(4):
      if t[j] > t[i]:
        t[j] -= 1
    t[i] = 3
    print(p, 'x', i, '->', perm_to_str(t), ':\t', bbin(perm_to_idx[p]), '\t', bbin(i), '\t', bbin(perm_to_idx[perm_to_str(t)]), end='\t')
    print(perm_to_idx[p], '\t', i, '\t', perm_to_idx[perm_to_str(t)])
