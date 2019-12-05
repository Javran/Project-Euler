module ProjectEuler.Problem141
  ( problem
  ) where

import ProjectEuler.Types

problem :: Problem
problem = pureProblem 141 Unsolved result

{-
  Looks like this will be one of those difficult ones.

  Say n = q * k + r.

  - First, we don't want any of those to be zero,
    since we want q,k,r to form geometric sequence (not in that particular order).
    Therefore: q > 0 & k > 0 & r > 0
  - Also 0 < r < q

  So r < q is already in place, leaving k only 3 choices:
  - k < r < q, in this case we can verify whether k * q == r * r
  - r < k < q, verify that r * q == k * k
  - r < q < k, verify that r * k == q * q

  Perhaps explore a bit more with each cases?

  - case #1: k < r < q => r * r = k * q

    n = q * k + r = r * (r + 1) = x * x

    Given that n > 0, there is no solution for when x > 0.

  - case #2: r < k < q => r * q = k * k, q = k * k / r

    n = q * k + r = k^3 / r + r, which needs to be a perfect square.

    Since r is an integer, so must be k^3 / r, which means k^3 === 0 (mod r)

  - case #3: r < q < k => r * k = q * q. k = q * q / r

    n = q * k + r = q^3 / r + r, which needs to be a perfect square.

 -}

result = ()

