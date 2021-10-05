{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE GADTs #-}

-- ex 1

import Data.Char (toLower)
import System.IO (IOMode(ReadMode, ReadWriteMode), openFile, stdout, hIsEOF, hGetChar, hPutChar, Handle, isEOF,  BufferMode(NoBuffering), hSetBuffering, stdin )
import Control.Monad (when)
import Control.Monad.State
import Control.Concurrent (threadDelay)
import Control.Monad.Trans.Maybe
import System.Environment (getArgs)
sprintf d = d id ""

int :: (String -> a) -> String -> Integer  -> a
int f str n = f $ str ++ show n

str :: (String -> a) -> String -> String -> a
str f str str2 =  f $ str ++ str2

lit :: String -> (String -> a) -> String -> a
lit str c str2 = c $ str2 ++ str

(^^) = (.)

fstring = sprintf (str . lit " ma " . int . lit " kot" . str . lit ".")
string = fstring "Adrzej" 2 "y"

-- ex 2 

-- type Format a b = (String -> a) -> String -> b

-- data Format a b where
--     Lit :: String -> Format (String -> a) (String -> a)
--     Int :: Format (String -> a) (Int -> a)
--     Str :: Format a (String -> a)
--     (:^:) :: Format a c -> Format c b -> Format a b 

data Format a b where
    Lit :: String -> Format a a
    Int :: Format a (Int -> a)
    Str :: Format a (String -> a)
    (:^:) :: Format c b -> Format a c -> Format a b 

--          2.ja to tak zamienie   1. powiedz co z tym zrobic      3. i dostaniesz coś innego
ksprintf :: Format a b              -> (String -> a) ->                 String -> b
ksprintf (Lit str) c = \s -> c (s ++ str)
ksprintf Int       c = \s n -> c ( s ++ show n) 
ksprintf Str       c = \s t -> c (s ++ t)
ksprintf (a :^: b) c = ksprintf a $ ksprintf b c

kprintf :: Format a b -> (IO () -> a) -> IO () -> b
kprintf (Lit str) c = \s -> c (s >> putStr str)
kprintf Int       c = \s n -> c ( s >> putStr (show n))
kprintf Str       c = \s t -> c ( s >> putStr t)
kprintf (a :^: b) c = kprintf a $ kprintf b c

-- printf :: Format a b -> IO ()
printf fmt = kprintf fmt (>> putStrLn "") (return ())

sprimtf d = ksprintf d id "" 

fmt = Str :^: Lit " ma " :^: Int :^: Lit " kot" :^: Str :^: Lit "..."

fstrimg = sprimtf $ Str :^: Lit " ma " :^: Int :^: Lit " kot" :^: Str :^: Lit "..."

-- ex 3

echoLower :: IO ()
echoLower = do
    hSetBuffering stdin NoBuffering 
    getContents >>= putStr . map toLower

-- ex 4

data StreamTrans i o a 
    = Return a
    | ReadS (Maybe i -> StreamTrans i o a)
    | WriteS o (StreamTrans i o a)

toLowerStr :: StreamTrans Char Char ()
toLowerStr = ReadS f
    where f (Just i) = WriteS (toLower i) toLowerStr
          f Nothing  = Return ()

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

-- main = do
--     hSetBuffering stdin NoBuffering
--     runIOStreamTrans toLowerStr

-- ex 5

safeHead [] = Nothing 
safeHead (x : xs) = Just x

safeTail [] = []
safeTail (x : xs) = xs

listTrans :: StreamTrans i o a -> [i] -> ([o], a)
listTrans (Return a) xs     = ([] , a)
listTrans (ReadS f)  xs     = listTrans (f $ safeHead xs) (safeTail xs)
listTrans (WriteS o str) xs = let (ys, a) = listTrans str xs
                              in (o : ys, a) 


-- ex 6

-- wersja która działą sensowanie dla transformatorów które na zmianę wczytują i wypisują
runCycle :: StreamTrans a a b -> b
runCycle (Return b) = b
runCycle (ReadS f) = runCycle $ f Nothing -- meh
runCycle (WriteS o (ReadS f)) = runCycle (f $ Just o)
runCycle (WriteS o str) = runCycle str

runCycleIO :: Show a => StreamTrans a a b -> IO b
runCycleIO (Return b) = return b
runCycleIO (ReadS f) = runCycleIO $ f Nothing -- meh
runCycleIO (WriteS o (ReadS f)) = print o >> threadDelay 500000 >> runCycleIO (f $ Just o)
runCycleIO (WriteS o str) = runCycleIO str

-- str1 n j = if j > 0 then 
--                 WriteS n (ReadS (\case Nothing -> Return n
--                                        Just i  -> WriteS (n + i) (str1 (n+i) (j-1))))
--            else Return n


str1 n = WriteS n (ReadS (\case Nothing -> Return "akuku"
                                Just i  -> WriteS (n + i) (str1 (n+i))))

-- str2 n = WriteS (n+1) (str1 n)

-- -- wersja która akumuluje cały output, jeśli ma coś do przekazania do inputa to przekazuje
-- runCycle1 :: StreamTrans a a b -> b
-- runCycle1 = undefined 
--     where
--         -- runCycleK :: ([a], (StreamTrans a a b)) -> ([a], (StreamTrans a a b))
--         -- runCycleK (ys, (ReadS f)) = (safeTail ys , f $ safeHead ys)
--         -- runCycleK (ReadS f) = undefined 
--         -- runCycleK (WriteS o str) = undefined    

-- ex 7

(|>|) :: StreamTrans i m a -> StreamTrans m o b -> StreamTrans i o b
_           |>| Return b     = Return b
ReadS f     |>| st           = ReadS $ \i -> f i |>| st
st1         |>| WriteS o st2 = WriteS o (st1 |>| st2)
WriteS o st |>| ReadS f      = st |>| f (Just o)
st          |>| ReadS f      = st |>| f Nothing


-- ex 8

catchOutput :: StreamTrans i o a -> StreamTrans i b (a, [o])
catchOutput = catchOutput' []
    where
        catchOutput' os (Return a) = Return (a, reverse os)
        catchOutput' os (ReadS f)  = ReadS $ catchOutput' os . f
        catchOutput' os (WriteS o str) = catchOutput' (o:os) str


-- main = do
--     hSetBuffering stdin NoBuffering
--     let (outs1, ((), outs2)) = listTrans (catchOutput toLowerStr) ['a', 'b', 'G', 'F']
--     -- outs1 are catchOutput outputs - ambigous empty outputs 
--     print outs2

-- ex 9

data BF
    = MoveR      -- >
    | MoveL      -- <
    | Inc        -- +
    | Dec        -- -
    | Output     -- .
    | Input      -- ,
    | While [BF] -- [ ]
    deriving Show

readWhile :: (i -> Bool) -> StreamTrans i i ()
readWhile p = ReadS $ \case
    Nothing -> Return ()
    Just i  -> 
        if p i then
            WriteS i $ readWhile p
        else
            Return ()
                
brainfuckParser :: StreamTrans Char BF ()
brainfuckParser = ReadS $ \case
    Nothing -> Return ()
    Just c | c == '>' -> WriteS MoveR brainfuckParser
    Just c | c == '<' -> WriteS MoveL brainfuckParser
    Just c | c == '+' -> WriteS Inc brainfuckParser
    Just c | c == '-' -> WriteS Dec brainfuckParser
    Just c | c == '.' -> WriteS Output brainfuckParser
    Just c | c == ',' -> WriteS Input brainfuckParser
    Just c | c == '[' -> do (bl, bfs) <- catchOutput (readWhile (/= ']') |>| brainfuckParser) 
                            WriteS (While bfs) brainfuckParser
                            -- fajnie jakby parser zwracał zamiast () False, jeśli input się skończy zanim przeczytamy ']' 
    Just c            -> brainfuckParser

-- ex 10
coerceEnum :: (Enum a, Enum b) => a -> b
coerceEnum = toEnum . fromEnum

type Tape = ([Integer], [Integer])
evalBF :: Tape -> BF -> StreamTrans Char Char Tape
evalBF (l, r) MoveR       = Return (head r : l, tail r)
evalBF (l, r) MoveL       = Return (tail l, head l : r)
evalBF (l, r) Inc         = Return (l, 1 + head r : tail r)
evalBF (l, r) Dec         = Return (l, head r - 1 : tail r)
evalBF tp@(l, r) Output   = WriteS (coerceEnum $ head r) (Return tp)
evalBF (l, r) Input       = ReadS $ \case Just i -> Return (l , coerceEnum i : tail r)
                                          -- and what with nothing?
evalBF tp@(l, r) bf@(While bfs) =
    if head r == 0 then
        Return tp
    else do
        newtp <- evalBFBlcok tp bfs
        evalBF newtp bf  

evalBFBlcok :: Tape -> [BF] -> StreamTrans Char Char Tape
evalBFBlcok = foldM evalBF

runBF :: [BF] -> StreamTrans Char Char ()
runBF = foldM_ evalBF (repeat 0, repeat 0)

-- runRealTime :: Tape -> StreamTrans i BF a -> StreamTrans BF (StreamTrans Char Char Tape) -> 

-- ex 11

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
                        --   f >=> g
    WriteS o s >>= f = WriteS o (s >>= f)

main = do
    filename : _ <- getArgs
    handle <- openFile filename ReadMode
    ((), bfs) <- runIOStreamTransWithHandles handle handle $ catchOutput brainfuckParser
    runIOStreamTrans $ runBF bfs