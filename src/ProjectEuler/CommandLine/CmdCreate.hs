{-# LANGUAGE
    OverloadedStrings
  , TypeApplications
  #-}
module ProjectEuler.CommandLine.CmdCreate
  ( cmdCreate
  ) where

import System.Directory
import System.Exit

import qualified Data.Text.Lazy.IO as TL
import qualified Filesystem.Path.CurrentOS as FP

import ProjectEuler.CommandLine.Common
import ProjectEuler.CommandLine.CmdSync

cmdCreate :: [String] -> IO ()
cmdCreate xs
  | [rawN] <- xs
  , [(pId,"")] <- reads @Int rawN
  = do
      prjHome <- getProjectHome
      let newProblemPath = solutionPath prjHome pId
      contents <- renderProblem pId False ""
      let fp = FP.encodeString newProblemPath
      e <- doesFileExist fp
      if e
        then do
          putStrLn $ "Cannot create " <> fp <> ", file already exists."
          exitFailure
        else do
          TL.writeFile fp contents
          putStrLn $
            "Problem created in " <> FP.encodeString newProblemPath
      cmdSync []
  | otherwise = do
      putStrLn "pet create <problem id>"
      exitFailure
