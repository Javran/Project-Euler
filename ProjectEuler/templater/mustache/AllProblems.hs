{-
  DO NOT EDIT: this file is generated/edited by templater.
 -}
module ProjectEuler.AllProblems
  ( allProblems
  ) where

import qualified Data.IntMap.Strict as IM

import ProjectEuler.Types

{{#problem_list}}
import ProjectEuler.Problem{{{val}}}
{{/problem_list}}

allProblems :: IM.IntMap Problem
allProblems =
  IM.fromList
{{#problem_list}}
    {{#first}}[{{/first}}{{^first}},{{/first}} ({{{val}}}, ProjectEuler.Problem{{{val}}}.problem)
{{/problem_list}}
    ]
