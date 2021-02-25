{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE GADTs #-}


import Data.Char (toLower)
import System.IO (IOMode(ReadMode, ReadWriteMode), openFile, stdout, hIsEOF, hGetChar, hPutChar, Handle, isEOF,  BufferMode(NoBuffering), hSetBuffering, stdin )
import Control.Monad (when)
import Control.Monad.State
import Control.Concurrent (threadDelay)
import Control.Monad.Trans.Maybe
import System.Environment (getArgs)

-- Zadanie 1

int :: (String -> a) -> String -> Integer -> a
int f s n = f (s ++ show n)

str :: (String -> a) -> String -> String -> a
str f s1 s2 = f (s1 ++ s2)

lit :: String -> (String -> a) -> String -> a
lit s f s2 = f (s2 ++ s)

(^^) :: (b -> c) -> (a -> b) -> a -> c
(^^) f g x = f (g x)
 
sprintf :: ((a -> a) -> [Char] -> t) -> t
sprintf f = f id ""

-- Zadanie 2

data Format a b where
  Lit :: String -> Format a a
  Int :: Format a (Int -> a)
  Str :: Format a (String -> a)
  (:^:) :: Format c b -> Format a c -> Format a b


ksprintf :: Format a b -> (String -> a) -> String -> b
ksprintf (Lit s1) cont = \s2 -> cont (s2 ++ s1)
ksprintf Int cont = \s n -> cont (s ++ show n)
ksprintf Str cont = \s1 s2 -> cont (s1 ++ s2)
ksprintf (a :^: b) cont = ksprintf a (ksprintf b cont) 

kprintf :: Format a b -> (IO () -> a) -> b
kprintf (Lit s1) cont = cont (putStr s1)
kprintf Int cont = \n -> cont (putStr (show n))
kprintf Str cont = \s -> cont (putStr s)
kprintf (a :^: b) cont = kprintf a (\s1 -> kprintf b (\s2 -> cont (s1 >> s2)))

printf :: Format (IO ()) b -> b
printf frmt = kprintf frmt id

sprintf2 :: Format String b -> b
sprintf2 frmt = ksprintf frmt id ""


-- Zadanie 3

echoLower :: IO ()
echoLower = do x <- getChar
               putChar (toLower x)
               echoLower

-- Zadanie 4

data StreamTrans i o a
  = Return a
  | ReadS (Maybe i -> StreamTrans i o a)
  | WriteS o (StreamTrans i o a)

myToLower :: StreamTrans Char Char ()
myToLower = ReadS f where
  f (Just i) = WriteS (toLower i) myToLower
  f Nothing = Return ()

runStreams :: StreamTrans Char Char a -> IO a
runStreams (Return a) = return a
runStreams (ReadS f) = do
  eof <- isEOF 
  if eof
    then runStreams (f Nothing)
  else do
    c <- getChar
    runStreams (f (Just c)) 
runStreams (WriteS out str) = do 
  putChar out
  runStreams str

-- Zadanie 5

listTrans :: StreamTrans i o a -> [i] -> ([o], a)
listTrans (Return a) xs = ([], a)
listTrans (ReadS f) [] = listTrans (f Nothing) []
listTrans (ReadS f) (x:xs) = listTrans (f (Just x)) xs
listTrans (WriteS out str) xs = 
  let (ys, a) = listTrans str xs
  in (out : ys, a)

-- Zadanie 6

runCycle :: StreamTrans a a b -> b
runCycle (Return b) = b
runCycle (ReadS f) = runCycle (f Nothing)
runCycle (WriteS out (ReadS f)) = runCycle (f (Just out))
runCycle (WriteS _ str) = runCycle str

-- Zadanie 7

(|>|) :: StreamTrans i m a -> StreamTrans m o b -> StreamTrans i o b
_ |>| Return b = Return b
ReadS f |>| stream = ReadS (\input -> (f input) |>| stream)
WriteS out stream |>| ReadS f = stream |>| f (Just out)
stream1 |>| WriteS out stream2 = WriteS out (stream1 |>| stream2)
stream |>| ReadS f = stream |>| f Nothing

-- Zadanie 8

catchOutput :: StreamTrans i o a -> StreamTrans i b (a, [o])
catchOutput = aux [] 
  where
    aux xs (Return a) = Return (a, xs)
    aux xs (ReadS f) = ReadS (\i -> aux xs (f i))
    aux xs (WriteS out stream) = aux (out : xs) stream

-- Zadanie 9

data BF
    = MoveR      -- >
    | MoveL      -- <
    | Inc        -- +
    | Dec        -- -
    | Output     -- .
    | Input      -- ,
    | While [BF] -- [ ]
    deriving Show

brainfuckParser :: StreamTrans Char BF Bool
brainfuckParser = ReadS $ \x -> case x of
    Nothing -> Return False
    Just '>' -> WriteS MoveR brainfuckParser
    Just '<' -> WriteS MoveL brainfuckParser
    Just '+' -> WriteS Inc brainfuckParser
    Just '-' -> WriteS Dec brainfuckParser
    Just '.' -> WriteS Output brainfuckParser
    Just ',' -> WriteS Input brainfuckParser
    Just '[' -> do  (b, loop) <- catchOutput brainfuckParser
                    if b then WriteS (While loop) brainfuckParser
                    else Return False
    Just ']' -> Return True
    Just _ -> brainfuckParser

-- Zadanie 10

type Tape = ([Integer], [Integer])
evalBF :: Tape -> BF -> StreamTrans Char Char Tape
evalBF (xs, y : ys) MoveR  = Return (y : xs, ys)
evalBF (x : xs, ys) MoveL  = Return (xs, x : ys)
evalBF (xs, y : ys) Inc    = Return (xs, (y + 1) : ys)
evalBF (xs, y : ys) Dec    = Return (xs, (y - 1) : ys)
evalBF (xs, y : ys) Output = WriteS (coerceEnum y :: Char) (Return (xs, y : ys))
evalBF (xs, y : ys) Input  = ReadS (\i -> case i of
                                            Nothing -> Return (xs, y : ys)
                                            Just i -> Return (xs, (coerceEnum i :: Integer) : ys))
evalBF (xs, y : ys) (While loop) = 
  if y == 0 then Return (xs, y : ys)
  else do
    loopTape <- evalBFBlock (xs, y : ys) loop
    evalBF loopTape (While loop)

evalBFBlock :: Tape -> [BF] -> StreamTrans Char Char Tape
evalBFBlock tape [] = Return tape
evalBFBlock tape (bf : bfcode) = 
  do result <- evalBF tape bf
     evalBFBlock result bfcode 

coerceEnum :: (Enum a, Enum b) => a -> b
coerceEnum = toEnum . fromEnum

runBF :: [BF] -> StreamTrans Char Char ()
runBF bfcode = do evalBFBlock (repeat 0, repeat 0) bfcode
                  return ()

runIOStreamTransWithHandles :: Handle -> Handle -> StreamTrans Char Char a -> IO a
runIOStreamTransWithHandles inp out (Return a) = return a
runIOStreamTransWithHandles inp out (ReadS f) = do 
    eof <- hIsEOF inp
    if eof then
        runIOStreamTransWithHandles inp out $ f Nothing 
    else do
        ch <- hGetChar inp
        runIOStreamTransWithHandles inp out $ f (Just ch)
runIOStreamTransWithHandles inp out (WriteS o str) = do
    hPutChar out o
    runIOStreamTransWithHandles inp out str

runIOStreamTrans :: StreamTrans Char Char a -> IO a
runIOStreamTrans = runIOStreamTransWithHandles stdin stdout

instance Functor (StreamTrans i o) where
    fmap f (Return a)   = Return $ f a
    fmap f (ReadS g)    = ReadS $ fmap f . g
    fmap f (WriteS o s) = WriteS o $ fmap f s

instance Applicative (StreamTrans i o) where
    Return f <*> s = fmap f s
    WriteS o sf <*> sa = WriteS o (sf <*> sa)
    ReadS g <*> s = ReadS $ (<*> s) . g
    pure = Return

instance Monad (StreamTrans i o) where
    Return a >>= f = f a
    ReadS g  >>= f = ReadS $ (>>= f) . g
    WriteS o s >>= f = WriteS o (s >>= f)

-- main = do
--     filename : _ <- getArgs
--     handle <- openFile filename ReadMode
--     (_, bfs) <- runIOStreamTransWithHandles handle handle $ catchOutput brainfuckParser
--     runIOStreamTrans $ runBF bfs


data BT a = L a | N (BT a) (BT a) 
  -- deriving show

tt = N (N (N (L 1) (L 2)) (L 4)) (L 3)

traverseBt :: BT a -> [a]
traverseBt (L x) = [x]
traverseBt (N tl tr) = (traverseBt tr) ++ (traverseBt tl)

witaj :: IO ()
witaj = putStr 