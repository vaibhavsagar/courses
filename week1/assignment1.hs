#!/usr/bin/env stack
-- stack --resolver lts-6.15 runghc

import Data.List (sort)

main = do
    array <- map read . lines <$> readFile "IntegerArray.txt" :: IO [Int]
    let inversions = countInversions array
    print $ snd inversions

countSortedInversions :: [Int] -> [Int] -> ([Int], Int) -> ([Int], Int)
countSortedInversions ll lr (lm, acc) = case (ll, lr) of
    ([], _)        -> (sort (lm ++ lr), acc)
    (_, [])        -> (sort (lm ++ ll), acc)
    (hl:tl, hr:tr)
        | hl <= hr -> countSortedInversions tl lr (sort (hl:lm), acc)
        | hr <  hl -> countSortedInversions ll tr (sort (hr:lm), acc + length ll)

countInversions :: [Int] -> ([Int], Int)
countInversions list
    | length list < 2  = (list, 0)
    | length list == 2 = let [h,t] = list in
        if h > t
            then (t:[h], 1)
            else (list,  0)
    | otherwise        = let
        half = length list `div` 2
        il@(ll, cl) = countInversions $ take half list
        ir@(lr, cr) = countInversions $ drop half list
        im@(lm, cm) = countSortedInversions (sort ll) (sort lr) ([], 0)
        in (lm, cl + cr + cm)
