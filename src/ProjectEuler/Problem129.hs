module ProjectEuler.Problem129
  ( problem
  , genInput
  , computeA
  ) where

import Petbox

import ProjectEuler.Types

problem :: Problem
problem = pureProblem 129 Solved result

{-
  Well, I really hoped that the description is something
  that normal human would understand.
  And as always not all things turn out to be what I hoped.

  So first few repunits are:

  R(1) = 1
  R(2) = 11
  R(3) = 111 = 3 x 37
  R(4) = 1111 = 11 x 101
  R(5) = 11111 = 41 x 271
  R(6) = 111111 = 3 x 7 x 11 x 13 x 37
  R(7) = 1111111 = 239 x 4649
  R(8) = 11111111 = 11 x 73 x 101 x 137
  R(9) = 111111111 = 3^2 x 37 x 333667
  R(10) = 1111111111 = 11 x 41 x 271 x 9091
  R(11) = 11111111111 = 21649 x 513239
  R(12) = 111111111111 = 3 x 7 x 11 x 13 x 37 x 101 x 9901
  R(13) = 1111111111111 = 53 x 79 x 265371653
  R(14) = 11111111111111 = 11 x 239 x 4649 x 909091
  R(15) = 111111111111111 = 3 x 31 x 37 x 41 x 271 x 2906161
  R(16) = 1111111111111111 = 11 x 17 x 73 x 101 x 137 x 5882353

  To find A(7), as 7 is a prime, simply lookup this table from up to down
  and find its first appearance, which is in R(6), therefore A(7) = 6.

  To find A(41), as 41 is a prime, repeat the same process.
  41 first appears in R(5), therefore A(41) = 5.

  So first few As:

  A(1) = 1
  A(3) = 3
  A(7) = 6
  A(9) = 8
  A(11) = 2
  A(13) = 6
  A(17) = 16, exceeds 10.

  Only those end with 1,3,7,9 are included, as we are only looking at
  those n s.t. GCD(n, 10) = 1.

  some interpretation: A(n) is the number of 1's in the repunit.

  So there's an opportunity of sharing results:
  say we computed that R(k) `mod` n = r:

  R(k+1) `mod` n
  > (R(k) * 10 + 1) `mod` n
  > ((R(k) `mod` n) * 10 + 1) `mod` n (since GCD(n, 10) = 1)

  This allows us to reuse r to check for R(k+1) `mod` n.

 -}

genInput :: Int -> [Int]
genInput base =
  concat $ iterate (fmap (+10)) (fmap (+base) [1,3,7,9])

computeA :: Int -> Int
computeA n = go 1 1
  where
    go 0 acc = acc
    go x acc = go ((x * 10 + 1) `rem` n) (acc+1)

result :: Int
result = firstSuchThat ((> 1000000) . computeA) $ genInput 1000000
