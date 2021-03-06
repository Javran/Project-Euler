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

  The following is mostly based on euler@'s comment.

  # tl;dr

  - once we write n = 2^u * r, when u >= 4, it is always possible to "distribute" a factor of 4
    to both m and v, in this case we always have multiple solutions to work with.
  - when u < 4, I have no better option than investigating one or several of them individually.
    this actually takes most of the spaces in my writeup.

  # full proof (still a bit informal)

  Now, let's begin with an overview of all cases that we need to consider:

             n = 1 | n = 2^u * p | n = 2^u * r_0 * r_1
    u = 0  | #1    | #2          | #10
    u = 1  | #1    | #5          | #5
    u = 2  | #1    | #3          | #7
    u = 3  | #6    | #6          | #6
    u = 4  | #2    | #4          | #8
    u > 4  | #8    | #9          | #8

  - case #1: n = 1 or 2 or 4 or 16.

    + n = 2^0 = 1 is impossible since n >= m > 1.
    + n = 2^1 = 2 is impossible since (m + v) === 0 (mod 4) cannot be satisfied.
    + n = 2^2 = 4

      We have a bunch of choices: (m, v) = (1, 4) or (2, 2) or (4, 1).
      but since we want m + v === 0 (mod 4) and m > 1, we only have one choice, which is (2, 2),
      which corresponds to 3^2 - 2^2 - 1^2 = 4.

    + n = 2^4 = 16

      Similar to case n = 4, we have (m, v) = (1, 16) or (2, 8), or (4, 4) or (8, 2) or (16, 1).
      But again we have only one valid choice: (m, v) = (4, 4),
      which corresponds to 6^2 - 4^2 - 2^2 = 16.

  - case #2: n = p where p is an odd prime.

    We have (m, v) = (1, p) or (p, 1) in this case,
    since m > 1, only (p, 1) could be valid.

    m + v === 0 (mod 4)
    > p + 1 === 0 (mod 4)
    > p === 3 (mod 4)

    To make sure that m > d, notice this condition is the same as n < 3 * m^2,
    plug in n = m = p, we have p < 3 * p^2, which trivially holds.

  - case #3: n = 4p.

    (m, v) = (p, 4) or (2p, 2) or (4p, 1) or (1, 4p) or (2, 2p) or (4, p).
    - m > 1 eliminates (1, 4p)
    - p + 4 === p === 0 (mod 4), which is impossible, eliminating (p,4) and (4,p)
    - 4p + 1 === 1 === 0 (mod 4), impossible, eliminating (4p, 1) and (1, 4p)
    - for (m, v) = (2, 2p), plug in n < 3*m^2, 4p < 3*4, p < 3, impossible.

    Now we have only (m, v) = (2p, 2). m + v = 2p + 2 = 2*(p + 1).
    since p is odd, 2*(p+1) === 0 (mod 4) holds. we have one solution in this case.

  - case #4: n = 16p.

    (m, v) = (1, 16p) or (2, 8p) or (4, 4p) or (8, 2p) or (16, p)
          or (16p, 1) or (8p, 2) or (4p, 4) or (2p, 8) or (p, 16).

    - 16p + 1, 8p + 2, 2p + 8, p + 16 are all impossible by some modular reasoning,
      leaving us (m, v) = (4, 4p) and (4p, 4)
    - with further constraint n < 3*m^2, we have only (m, v) = (4p, 4), which is a valid solution.

  Now for case #1 ~ #4, we have exactly one solutions, which happens to be all the cases that we need to include,
  for the rest of the section, let's consider all the other possibilities:

  - case #5: n = 2^u * r, u = 1. (i.e. n = 2 * r where r is odd)

    (m, v) = (1, 2r) or (2, r) or (r, 2) or (2r, 1).

    - 1 + 2r and 2 + r are always odd, therefore all of those are impossible.

  - case #6: n = 2^u * r, u = 3. (i.e. n = 8 * r where r is odd)

    - 8r + 1 , 4r + 2, 2r + 4, r + 8 are all impossible to be _ === 0 (mod 4).

  - case #7: n = 4 * r, where r is a composite.

    let r = r_0 * r_1. and we know both r_0 and r_1 are odd numbers.

    try all combinations of (m, v), we'll end up with 3 possibilities:

    (m,v) = (2r_0, 2r_1) or (2r_1, 2r_0) or (2r, 2)

    plug (m, v) = (2r, 2) into n < 3*m^2 => 4*r < 3*4*r*r, which always holds.

    Note that the remaining two are symmetric,
    plug in (m,v) = (2r_0, 2r_1) to n < 3*m^2:

    4 * r_0 * r_1 < 3 * 4 * r_0 * r_0
    > r_1 < 3 * r_0

    and by symmetricity we know r_0 < 3 * r_1 needs to hold for (2r_1, 2r_0).

    To invalidate both of them we have to verify
    r_1 >= 3*r_0 && r_0 >= 3*r_1, which would imply r_1 >= 3*r_1, which can never hold.
    Therefore we have at least two solutions for this case.

  - case #8: n = 2^u * r, where u > 3 and r is composite (r = r_0 * r1)

    - since u > 3, we can always put 2^2 on both side of (m, v),
      it's easy to see that
      - (m, v) = (2^(u-4) * 4 * r_0, 4 * r_1) or (2^(u-4) * 4 * r_1, 4 * r_o) gives at least one solution
      - so does (m, v) = (4 * r_0, 2^(u-4) * 4 * r_1) or (4 * r_1, 2^(u-4) * 4 * r_2)

    this is sufficient to show that more than one solution exists.

  - case #9: n = 2^u * p where u > 4.

    (m, v) = (2^(u-4)*4p, 4) or (2^(u-5)*4p, 8), at least.

  - case #10: n is odd and composite. let n = r_0 * r_1.

    for (m + v) === 0 (mod 4), it must be that
    (m === 1 (mod 4) and v === 3 (mod 4)) or the other way around.
    which suggests (m, v) = (n, 1) is also a valid solution.
    Therefore we either have more than one solution or have no solution at all.

 -}

{-
  n = 4, 16, p === 3 (mod 4), 4*p, 16*p are all the solutions
  (all `p`s are odd primes).
  This function expects that maxN > 16
  so we don't need to write conditions around n = 4 or 16.
 -}
countSameDiffs :: Int -> Int
countSameDiffs maxN =
    2 -- those two are for n = 4 and n = 16
    + caseA -- when n = p, p === 3 (mod 4)
    + caseB -- when n = 4*p
    + caseC -- when n = 16*p
  where
    oddPrimes = takeWhile (<= maxN) $ tail primes
    caseA = length . filter (\v -> v `rem` 4 == 3) $ oddPrimes
    caseB = length $ takeWhile (<= (maxN `quot` 4)) oddPrimes
    caseC = length $ takeWhile (<= (maxN `quot` 16)) oddPrimes

result :: Int
result = countSameDiffs (50000000-1)
