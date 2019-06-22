{-# LANGUAGE TemplateHaskell #-}
module ProjectEuler.GetData
  ( getDataFile
  , getDataDir
  , getDataRawContent
  , getDataContent
  ) where

import Control.Arrow
import Data.FileEmbed
import Data.Maybe
import Data.Text.Encoding (decodeUtf8)
import Paths_ProjectEuler
import System.FilePath

import qualified Data.ByteString as BS
import qualified Data.Map.Strict as M
import qualified Data.Text as T
import qualified System.IO.Strict as SIO

-- TODO: can we use file-embed here to completely get rid of
-- runtime IO overhead?

getDataFile :: String -> IO String
getDataFile fName = do
    dir <- getDataDir
    SIO.readFile (dir </> "data" </> fName)

{-
  Data files are constructed at compile time to reduce runtime overhead.

  Here we provides 2 versions of the same file:
  - ByteString version, if needed for parsing.
  - Text version, this will cover most use cases.
 -}
dataDirContents :: M.Map FilePath (BS.ByteString, T.Text)
dataDirContents = M.fromList $ second (\x -> (x, decodeUtf8 x)) <$> $(embedDir "data")

getDataPair :: FilePath -> (BS.ByteString, T.Text)
getDataPair p =
    {-
      The error raise is intentional because `data/` path
      is under version control and shouldn't contain any files
      that are unknown statically.
     -}
    fromMaybe err $ M.lookup p dataDirContents
  where
    err = error $ "Data file not found: " <> p

getDataRawContent :: FilePath -> BS.ByteString
getDataRawContent = fst . getDataPair

getDataContent :: FilePath -> T.Text
getDataContent = snd . getDataPair
