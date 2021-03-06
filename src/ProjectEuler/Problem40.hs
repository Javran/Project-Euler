module ProjectEuler.Problem40
  ( problem
  ) where

import Data.Char

import ProjectEuler.Types

problem :: Problem
problem = pureProblem 40 Solved result

_champSeq :: String
_champSeq = concatMap show [1 :: Int ..]

-- 1..9           => replicate (10-1) 1          =>   9  zone   1..    9, len =   9*1
-- 10..99         => replicate (100-10) 2        =>  90  zone  10..  189, len =  90*2
-- 100..999       => replicate (1000-100) 3      => 900  zone 190.. 2889, len = 900*3
-- 10^(n-1)..10^n => replicate (10^n-10^(n-1)) n => ...  zone
--
-- [9, 189, 2889 ..]
--
-- a[0] = 0
-- a[1] = 9 = 0 + (10 - 1) * 1
-- a[n] = a[n-1] + len
--     where
--         len = zone_size * n
--         zone_size = 10 ^ n - 10 ^ (n-1)
--
-- a[n] = a[n-1] + (10^n - 10^(n-1))*n
--

-- a list of pairs,
--   `fst` of which is the length of a number in this range
--   and the last digit in this range is the `snd`-th one
--   e.g.:
--     rangeMax = [(0,0),(1,9),(2,189), ...]
--     take 10 $ drop 189 champSeq == "1001011021"
--     i.e. 100, 101, 102, 103 ...
rangeMax :: [(Int,Int)]
rangeMax = iterate go (0,0)
  where
    go (n,prev) = (m,prev + (10^m - 10^(m-1))*m)
      where
        m = n+1

-- the n-th digit
theDigit :: Int -> Int
theDigit n = charToDigit digitChar
  where
    (numLen,rMax) = last $ takeWhile ((<=n).snd) rangeMax
    diff = n - rMax
    (numDiff,posDiff) = (diff-1) `divMod` (numLen + 1)
    num = 10^numLen + numDiff
    digitChar = show num !! posDiff

charToDigit :: Char -> Int
charToDigit c = ord c - ord '0'

result :: Int
result = product $ theDigit <$> posList
  where
    posList = take 7 $ iterate (*10) 1


