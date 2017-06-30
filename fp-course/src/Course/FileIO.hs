{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RebindableSyntax #-}

module Course.FileIO where

import Course.Core
import Course.Applicative
import Course.Monad
import Course.Functor
import Course.List

{-

Useful Functions --

  getArgs :: IO (List Chars)
  putStrLn :: Chars -> IO ()
  readFile :: Chars -> IO Chars
  lines :: Chars -> List Chars
  void :: IO a -> IO ()

Abstractions --
  Applicative, Monad:

    <$>, <*>, >>=, =<<, pure

Problem --
  Given a single argument of a file name, read that file,
  each line of that file contains the name of another file,
  read the referenced file and print out its name and contents.

Example --
Given file files.txt, containing:
  a.txt
  b.txt
  c.txt

And a.txt, containing:
  the contents of a

And b.txt, containing:
  the contents of b

And c.txt, containing:
  the contents of c

To test this module, load ghci in the root of the project directory, and do
    >> :main "share/files.txt"

Example output:

$ ghci
GHCi, version ... 
Loading package...
Loading ...
[ 1 of 28] Compiling (etc...
...
Ok, modules loaded: Course, etc...
>> :main "share/files.txt"
============ share/a.txt
the contents of a

============ share/b.txt
the contents of b

============ share/c.txt
the contents of c

-}

-- /Tip:/ use @getArgs@ and @run@
main ::
  IO ()
main = do
  args     <- getArgs
  let (h:._) = args
  (_,contents) <- getFile h
  run contents

type FilePath =
  Chars

-- /Tip:/ Use @getFiles@ and @printFiles@.
run ::
  Chars
  -> IO ()
run contents = do
  let paths = lines contents
  ws <- getFiles paths
  printFiles ws


getFiles ::
  List FilePath
  -> IO (List (FilePath, Chars))
getFiles Nil = return Nil
getFiles (h:.t) = do
  value  <- getFile  h
  values <- getFiles t
  return (value :. values)


getFile ::
  FilePath
  -> IO (FilePath, Chars)
getFile path = do
  contents <- readFile path
  return (path, contents)

printFiles ::
  List (FilePath, Chars)
  -> IO ()
printFiles Nil    = return ()
printFiles ((path,contents):.t) = printFile path contents >>= \_ -> printFiles t

printFile ::
  FilePath
  -> Chars
  -> IO ()
printFile path chars = do
  putStrLn $ "============ " ++ path
  putStrLn chars
