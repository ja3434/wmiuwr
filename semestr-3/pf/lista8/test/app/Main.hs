-- module Main where

silnia :: (Eq p, Num p) => p -> p
silnia n = if n == 0 then 1 else n * silnia (n -1)

fibs :: [Integer]
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

-- Zadanie 1

f :: [Integer] -> [Integer]
f (p : xs) = filter (\x -> x `mod` p /= 0) xs

primes :: [Integer]
primes = map head (iterate f [2 ..])

-- Zadanie 2

primes' :: [Integer]
primes' = 2 : [p | p <- [3 ..], all (\q -> p `mod` q /= 0) (takeWhile (\q -> q * q <= p) primes')]

-- Zadanie 3

permi :: [a] -> [[a]]
permi [] = [[]]
permi (x : []) = [[x]]
permi (p : xs) = concat [(iter [] perm) | perm <- permi xs]
  where
    iter pref [] = [pref ++ [p]]
    iter pref suf = (pref ++ (p : suf)) : (iter (pref ++ [head suf]) (tail suf))

perms :: [a] -> [[a]]
perms [] = [[]]
perms (x : []) = [[x]]
perms xs = iter [] [] xs
  where
    iter res pref [] = res
    iter res pref (x : xs) = iter (res ++ (map (\ys -> x : ys) (perms (pref ++ xs)))) (pref ++ [x]) xs

-- Zadanie 4

sublist :: [a] -> [[a]]
sublist [] = [[]]
sublist (x : xs) = sxs ++ (map (\xs -> x : xs) sxs)
  where
    sxs = sublist xs

-- Zadanie 5

qsortBy :: (a -> a -> Bool) -> [a] -> [a]
qsortBy _ [] = []
qsortBy _ [x] = [x]
qsortBy cmp (x : xs) = le ++ [x] ++ ge
  where
    le = qsortBy cmp [y | y <- xs, cmp x y]
    ge = qsortBy cmp [y | y <- xs, cmp y x]

-- Zadanie 6

-- subtable :: [a] -> Int -> [b] -> ([a] -> [a]) -> [a]
-- subtable [] _ _ _ = []
-- subtable _ _ [] _ = []
-- subtable xs maxLen ys f = getSubtableBounded (f (take maxLen xs)) ys
--   where
--     getSubtableBounded [] _ = []
--     getSubtableBounded _ [] = []
--     getSubtableBounded (x : xs) (_ : ys) = x : (getSubtableBounded xs ys)

-- natsBounded xs = iter [] 1 xs
--   where
--     iter res _ [] = res
--     iter res num (x : xs) = iter (res ++ [num]) (num + 1) xs

-- generateCantorTable :: [a] -> [b] -> ([a] -> [a]) -> [a]
-- generateCantorTable _ [] f = []
-- generateCantorTable [] _ f = []
-- generateCantorTable xs ys f = concat [subtable xs maxLen ys f | maxLen <- natsBounded xs]

-- (><) :: [a] -> [b] -> [(a, b)]
-- (><) xs ys = zip (generateCantorTable xs ys reverse) (generateCantorTable ys xs id)

-- (><) :: [a] -> [b] -> [(a, b)]
-- (><) [] _ = []
-- (><) _ [] = []
-- (><) xs ys = iterXS xs ys
--   where iterXS xs ys

-- Zadanie 7

data Tree a = Node (Tree a) a (Tree a) | Leaf

data Set a = Fin (Tree a) | Cofin (Tree a)

treeFromList :: Ord a => [a] -> Tree a
treeFromList [] = Leaf
treeFromList [x] = Node Leaf x Leaf
treeFromList xs =
  let center xs =
        let iter pref crawl [] = (pref, crawl)
            iter pref crawl [x] = (pref, crawl)
            iter pref crawl (x : y : xs) = iter (head crawl : pref) (tail crawl) xs
         in iter [] xs xs
   in let (st, nd) = center xs in Node (treeFromList (reverse st)) (head nd) (treeFromList (tail nd))

setFromList :: Ord a => [a] -> Set a
setFromList xs = Fin (treeFromList xs)

setEmpty :: Ord a => Set a
setEmpty = Fin Leaf

setFull :: Ord a => Set a
setFull = Cofin Leaf

setToList :: Ord a => Set a -> [a]
setToList (Fin t) = treeToList t
setToList (Cofin t) = treeToList t

treeToList :: Ord a => Tree a -> [a]
treeToList Leaf = []
treeToList (Node t1 a t2) = treeToList t1 ++ [a] ++ treeToList t2

merge :: Ord a => [a] -> [a] -> [a]
merge [] ys = ys
merge xs [] = xs
merge (x : xs) (y : ys) = if x < y then x : (merge xs (y : ys)) else y : (merge (x : xs) ys)

setUnion :: Ord a => Set a -> Set a -> Set a
setUnion (Fin t1) (Fin t2) =
  setFromList (treeToList t1 `merge` treeToList t2)
setUnion (Fin t1) (Cofin t2) =
  Cofin (treeFromList [x | x <- treeToList t2, x `notElem` treeToList t1])
setUnion (Cofin t1) (Fin t2) = setUnion (Fin t2) (Cofin t1)
setUnion (Cofin t1) (Cofin t2) =
  Cofin (treeFromList [x | x <- treeToList t1, x `elem` treeToList t2])

setIntersection :: Ord a => Set a -> Set a -> Set a
setIntersection (Fin t1) (Fin t2) =
  setFromList [x | x <- treeToList t1, x `elem` treeToList t2]
setIntersection (Fin t1) (Cofin t2) =
  setFromList [x | x <- treeToList t1, x `notElem` treeToList t2]
setIntersection (Cofin t1) (Fin t2) =
  setIntersection (Fin t1) (Cofin t2)

-- setIntersection (Cofin t1) (Cofin t2) =
--   Cofin (treeFromList [x | x <- treeToList t1, ])

treeMember :: Ord a => a -> Tree a -> Bool
treeMember _ Leaf = False
treeMember x (Node t1 y t2) =
  (x == y) || if x < y then treeMember x t1 else treeMember x t2

setMember :: Ord a => a -> Set a -> Bool
setMember x (Cofin t) = not (x `treeMember` t)
setMember x (Fin t) = x `treeMember` t