module ProjectEuler.Problem136
  ( problem
  ) where

import Petbox

import ProjectEuler.Types

problem :: Problem
problem = pureProblem 136 Solved result

{-
  Using same method as in Problem135 works,
  but it is a bit slower than I like.

  There are various ways that we can do a better job based on the brute force
  we established in Problem135,
  but I don't think we can have any significant improvement along that path.

  The following is mostly done after I've solved the problem,
  to both convince myself and whoever reading this that a solution
  better than brute force exists.

  Carrying over from Problem135:

  (m+d)^2 - m^2 - (m-d)^2 = n > 0.

  w.l.o.g.: m > d > 0

  - m > 1.
  - (m+d)^2 - m^2 - (m-d)^2 = (4 d - m) * m = n > 0
  - d < m, or equivalently n < 3 * m^2

  And for Problem136, we want to explore:
  "when is the solution (m,d) unique, given n?"

  Let's focus on `n = (4d - m) * m` for now:

  - let v = 4d - m, we have n = v * m && m + v = 4d
    (N.B. I'm not sure why we define v in the first place,
    my guess is that it makes the writing a bit easier)
  - here the idea is to explore all pairs (v, m)
    and find those m + v = 4d and check their validities.
  - let n = 2^u * r, where u >= 0 and r is an odd number.
    In other words, 2^u is all the "even-ness" of n.

  TODO: the following is mostly based on euler@'s comment - I'll still need to
  see how to go between steps and steps, but I think for now it doesn't hurt to write down
  what we have for now.

  - case #1: n = 4.

    We have a bunch of choices: (m, v) = (1, 4) or (2, 2) or (4, 1).
    but since we want m + v === 0 (mod 4) and m > 1, we only have one choice, which is (2, 2),
    which corresponds to 3^2 - 2^2 - 1^2 = 4.

  - case #2: n = 16.

    Similar to case #1, we have (m, v) = (1, 16) or (2, 8), or (4, 4) or (8, 2) or (16, 1).
    But again we have only one valid choice: (m, v) = (4, 4),
    which corresponds to 6^2 - 4^2 - 2^2 = 16.

  - case #3: n = p where p is an odd prime.

    We have (m, v) = (1, p) or (p, 1) in this case,
    since m > 1, only (p, 1) could be valid.

    m + v === 0 (mod 4)
    > p + 1 === 0 (mod 4)
    > p === 3 (mod 4)

    To make sure that m > d, notice this condition is the same as n < 3 * m^2,
    plug in n = m = p, we have p < 3 * p^2, which trivially holds.

  TODO: finish this.

 -}

{-
  n = 4, 16, p === 3 (mod 4), 4*p, 16*p are all the solutions (p > 2 therefore is odd)
  (TODO: proof pending)

  note: maxN > 16
 -}
countSameDiffs :: Int -> Int
countSameDiffs maxN = 2 + case1 + case2 + case3
  where
    oddPrimes = takeWhile (<= maxN) $ tail primes
    case1 = length . filter (\v -> v `rem` 4 == 3) $ oddPrimes
    case2 = length $ takeWhile (<= (maxN `quot` 4)) oddPrimes
    case3 = length $ takeWhile (<= (maxN `quot` 16)) oddPrimes

result :: Int
result = countSameDiffs (50000000-1)
