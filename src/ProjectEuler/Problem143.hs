{-# LANGUAGE LambdaCase #-}
module ProjectEuler.Problem143
  ( problem
  ) where

import Data.List
import Petbox
import Math.NumberTheory.Powers.Squares
import Control.Monad
import Debug.Trace

import qualified Data.DList as DL
import qualified Data.IntMap.Strict as IM

import ProjectEuler.Types

problem :: Problem
problem = pureProblem 143 Unsolved result

{-
  Idea:

  Reading some part of https://en.wikipedia.org/wiki/Fermat_point gives me the idea that,
  in our case where all angles are less than 2pi / 3, angle ATB = BTC = CTA = 2 pi / 3.

  From this insight, we can:
  - start from a "barebone" that divides 2 pi evenly into 3 parts with segment p, q and r
    (by doing so, we can bound on p+q+r more easily)
  - connect their other sides to form the triangle, and check whether a,b,c are all integers.
    note that by applying cosine rules, we have:

    + a^2 = r^2 + q^2 + r*q
    + b^2 = p^2 + q^2 + p*q
    + c^2 = p^2 + r^2 + p*r

  A brute force search is slow but is fast enough to get to an answer.

  My original approach is to enumerate 0 < a <= b <= c and figure out p,q,r that way.
  But this approach has several drawbacks:

  - There is no clear way to bound on p+q+r.

  - I wasn't aware that p, q, r are all required to be integer, not just p,q,r.

    You probably have noticed that:

    fmap (/7) [399,455,511,784] == [57.0,65.0,73.0,112.0]

    Unaware of this constraint on p,q,r leads me to many spurious tuples.

  - I've tried many ways to reduce the amount of search space,
    you can find many of my writeups in older version of this file,
    but with algorithm established, optimization can only get you so far.

  However there is one thing I do want to keep here so we can appreciate it:

  p + q + r = sqrt((a^2+b^2+c^2 + sqrt(3)*sqrt((a^2 + b^2 + c^2)^2 - 2*(a^4 + b^4 + c^4)))/2)

  The efficient method is described in the overview after solving the problem.

 -}

maxSum :: Int
maxSum = 120000

{-
  Below is the brute force approach.
  Sufficiently fast to get an answer, but the speed isn't impressive.
 -}
genTuples :: [Int]
genTuples = do
  -- assume that p <= q <= r
  r <- [1 :: Int .. maxSum]
  q <- [1..r]
  let gcdRQ = gcd r q
  -- we are at most computing 120000^2 * 3, using Int will not blow up.
  Just _a <- [exactSquareRoot (r*r + q*q + r*q)]
  p <- filter ((== 1) . gcd gcdRQ) [1.. min q (maxSum - r - q)]
  Just _b <- [exactSquareRoot (p*p + q*q + p*q)]
  Just _c <- [exactSquareRoot (p*p + r*r + p*r)]
  pure $ p+q+r

_result :: Int
_result = sum $ nub $ concatMap dup genTuples
  where
    dup x = takeWhile (<= maxSum) $ iterate (+ x) x

{-
  This is the "overview" method:

  - p = 2 m n + n^2
  - q = m^2 - n^2
  - r = m^2 + m n + n^2

  With m > n, gcd(m,n) = 1 and (m - n) `mod` 3 /= 0.
  Note that here we know r > q and r > p, but both p > q and p < q are possible.
 -}

type PrimTuple = (Int, Int, Int) -- p <= q <= r

{-
  Build up primitive tuples indexed by two shorter sides of the triangle.
 -}
prims :: IM.IntMap [PrimTuple]
prims =
    -- this filter rules out values that are singleton lists.
    -- since we want to pick 3 triangles that can join together to form a larger one,
    -- those singletons are never useful.
    {-
    IM.filter (\case
                  -- no case for empty list.
                  -- due to the fact that this is a dictionary, there's no need of that.
                  [_] -> False
                  _ -> True)
    . -} IM.map DL.toList
    . IM.fromListWith (<>)
    $ concatMap
        (\t@(p,q,_) -> let d = DL.singleton t in [(p,d),(q,d)])
        primTuples
  where
    {-
      p + q + r <= maxSum

      Here we can relax this constraint to make it a bit easier:

      p + q + 1 <= maxSum

      p + q + 1
      = 2 m n + n^2 + m^2 - n^2
      = 2 m n + m^2 + 1 <= 2m^2 + m^2 + 1 == 3m^2 + 1 <= maxSum

      3m^2 < maxSum

      Well, let's just say m <= integerSquareRoot (maxSum / 3),
      once we have the triple, fine-grain checks can be applied.
     -}
    maxM = integerSquareRoot' (div maxSum  3)
    primTuples :: [] PrimTuple
    primTuples = do
      m <- [1..maxM]
      n <- [1..m-1]
      -- Note: p,q,r here is confusing myself.
      let p = 2*m*n + n*n
          q = m*m - n*n
          r = m*m + m*n + n*n
      {-
        Note: this generation only generates primitive tuples,
        we'll need to include those scaled as well.
       -}
      pure $ if p <= q then (p,q,r) else (q,p,r)

doSearch = do
  (p, tsPre) <- IM.toAscList prims
  -- assume p is the shortest of three.
  let ts = filter (\(u,v,_) -> u >= p && v >= p) tsPre
  -- pick two tuples from the list
  ((x0,y0,_),ts0) <- pickInOrder ts
  ((x1,y1,_),_) <- pickInOrder ts0
  let q = if x0 == p then y0 else x0
      r = if x1 == p then y1 else x1
  Just vs <- [prims IM.!? min q r]
  guard $ any (\(x,y,_z) -> (x,y) == if q <= r then (q,r) else (r,q)) vs
  pure (p,q,r)

result = _result -- show prims
