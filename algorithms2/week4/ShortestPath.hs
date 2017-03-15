{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.IntMap.Strict          as IM
import qualified Data.HashMap.Strict         as H
import qualified Data.ByteString             as B
import qualified Data.ByteString.Char8       as BC
import qualified Data.Vector.Unboxed         as V
import qualified Data.Vector.Unboxed.Mutable as M
import Control.Monad.ST
import Control.Monad
import Data.STRef

import Data.List (groupBy)
import Data.Maybe (fromJust)
import Data.Function (on)
import Data.HashTable.ST.Basic
import qualified Data.HashTable.Class as HC
import Prelude hiding (lookup)
import Control.Concurrent.Async

import Debug.Trace

main = do
    g1 <- tail . map (map (fst . fromJust . BC.readInt) . BC.words) . BC.lines <$> B.readFile "g1.txt"
    g2 <- tail . map (map (fst . fromJust . BC.readInt) . BC.words) . BC.lines <$> B.readFile "g2.txt"
    g3 <- tail . map (map (fst . fromJust . BC.readInt) . BC.words) . BC.lines <$> B.readFile "g3.txt"
    results <- mapConcurrently (return . floydWarshall) [g1, g2, g3]
    print results

bellmanFord graph source = runST $ do
    let len = head (last graph) + 1
    dist <- M.replicate len (maxBound :: Int)
    M.write dist source 0
    forM_ [1..(len - 1)] $ \_ ->
        forM_ graph $ \[v, u, w] -> do
            distU <- M.read dist u
            distV <- M.read dist v
            when ((distU /= (maxBound :: Int)) && (distU + w) < distV) $
                M.write dist v (distU + w)
    frozen <- V.minimum <$> V.freeze dist
    result <- newSTRef (Right frozen)
    forM_ graph $ \[v, u, w] -> do
        distU <- M.read dist u
        distV <- M.read dist v
        when (distU /= (maxBound :: Int) && distU + w < distV) $
                writeSTRef result (Left "cycle found")
    readSTRef result

floydWarshall :: [[Int]] -> Either String Int
floydWarshall graph = runST $ do
    let len = head (last graph)
    let large = (maxBound :: Int) `div` 4
    dist <- HC.fromList [((i,j), large) | i <- [1..len], j <- [1..len]]
    forM_ [1..len] $ \i -> insert dist (i,i) 0
    forM_ graph $ \[u, v, w] -> insert dist (u,v) w
    forM_ [1..len] $ \k -> do
        forM_ [1..len] $ \i ->
            forM_ [1..len] $ \j -> do
                distIJ <- fromJust <$> lookup dist (i,j)
                distIK <- fromJust <$> lookup dist (i,k)
                distKJ <- fromJust <$> lookup dist (k,j)
                when (distIJ > distIK + distKJ) $ insert dist (i,j) (distIK + distKJ)
        when (k `mod` 10 == 0) $ traceShowM k
    asList <- HC.toList dist
    result <- newSTRef . Right . minimum $ map snd asList
    forM_ [1..len] $ \c -> do
        path <- fromJust <$> lookup dist (c,c)
        when (path < 0) $ writeSTRef result (Left "cycle found")
    readSTRef result
