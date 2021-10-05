-- Zadanie 1

int :: (String -> a) -> String -> Integer -> a
int f s n = f (s ++ show n)

str :: (String -> a) -> String -> String -> a
str f s1 s2 = f (s1 ++ s2)

lit :: String -> (String -> a) -> String -> a
lit s f s2 = f (s2 ++ s)

(^^) :: (b -> c) -> (a -> b) -> a -> c
(^^) = (.)

sprintf :: ((String -> a) -> String -> String) -> String
sprintf f = f id ""