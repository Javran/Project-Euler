{-# LANGUAGE
    TemplateHaskell
  , TypeApplications
  , OverloadedStrings
  #-}
module ProjectEuler.GetData
  ( getDataRawContent
  , getDataContent
  , expectedAnswers
  , getExpectedAnswers
  ) where

import Control.Applicative
import Control.Arrow
import Control.Exception
import Data.Aeson
import Data.Aeson.Types
import Data.Coerce
import Data.FileEmbed
import Data.Foldable
import Data.Maybe
import Data.Scientific
import Data.Text.Encoding (decodeUtf8)
import TextShow

import qualified Data.ByteString as BS
import qualified Data.HashMap.Strict as HM
import qualified Data.IntMap.Strict as IM
import qualified Data.Map.Strict as M
import qualified Data.Text as T
import qualified Data.Yaml as Yaml

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

newtype Answers = Answers (IM.IntMap [T.Text]) deriving Show

instance FromJSON Answers where
  parseJSON =
    withObject "Answers" $ \v -> do
        obj <- v .: "answers"
        Answers . IM.fromList <$> mapM convert (HM.toList obj)
      where
        convert :: (T.Text, Value) -> Parser (Int, [T.Text])
        convert (t, xs) = do
          [(v, "")] <- pure $ reads (T.unpack t)
          let convertAnswerOuts :: Array -> Parser [T.Text]
              convertAnswerOuts = mapM convertLine . toList
                where
                  scientificToInteger :: Scientific -> Parser Integer
                  scientificToInteger s = do
                    Right i <- pure (floatingOrInteger @Double s)
                    pure i

                  {-
                    First interpret the field as Text,
                    in case of failure, try Integer and convert it to Text.

                    this allows writing:

                    > - 12345

                    instead of the verbose version:

                    > - "12345"

                   -}
                  convertLine v' =
                    withText "OutputLine" pure v'
                    <|> withScientific
                          "OutputLine"
                          ((showt @Integer <$>) . scientificToInteger)
                          v'
          ys <- withArray "AnswerList" convertAnswerOuts xs
          pure (v, ys)

expectedAnswers :: IM.IntMap [T.Text]
expectedAnswers = case Yaml.decodeEither' $ getDataRawContent "answers.yaml" of
  Left e -> error (displayException e)
  Right a -> coerce @Answers a

getExpectedAnswers :: Int -> Maybe [T.Text]
getExpectedAnswers pId = IM.lookup pId expectedAnswers
