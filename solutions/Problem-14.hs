import Control.Applicative
import Control.Arrow
import Control.Monad.State
import qualified Data.Map.Strict as M
import Data.Int
import Data.Array
import Data.Array.ST
import Control.Monad.ST
import Data.Function
import Data.List

collatz :: Integral a => a -> a
collatz n = if odd n
              then 3 * n + 1
              else n `div` 2

limit :: Integral a => a
limit = 1000000

-- Int is sufficient as it's guaranteed to store at lease 2^29 - 1
collatzArray :: Array Int Int
collatzArray = runSTArray $ do
    ar <- newArray (1,limit) 0
    let calc 1 = return 1
        calc n = if n > limit
          then (+ 1) <$> calc (collatz n)
          else do
            v <- readArray ar n
            if v /= 0
               then return v
               else do
                 v' <- (+ 1) <$> calc (collatz n)
                 writeArray ar n v'
                 return v'
    mapM_ calc [1..limit]
    return ar

main :: IO ()
main = print $ maximumBy (compare `on` snd) (assocs collatzArray)
