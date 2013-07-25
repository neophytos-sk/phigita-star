import Control.Monad
import Data.Array.IO
import Data.List
import Data.IORef

import qualified Data.ByteString.Char8 as B



kosaraju n a ra = do
  
  e <- newArray (1,n) True :: IO (IOArray Int Bool) -- Unexplored?
  s <- newIORef [] -- Stack
  
  let
    dfs g i = dfs' i where
      dfs' i = do
        writeArray e i False
        readArray g i >>= mapM_ (\u -> readArray e u >>= \unexplored ->
                                  if unexplored then dfs' u else return ())
        modifyIORef s (i:)
  
    dfsLoop = mapM_ (\i -> readArray e i >>= flip when (dfs a i)) [n,n-1..1]
      
  putStrLn "First run..."
  dfsLoop

  putStrLn "Second run..."
  leaders <- readIORef s
  mapM_ (\i -> writeArray e i True) [1..n] -- make all unexplored
  scc <- mapM (\u -> readArray e u >>= \unexplored -> 
                if unexplored then writeIORef s [] >> dfs ra u >> readIORef s
                else return [])  leaders
  let sizes = reverse $ sort $ map length scc
  print (take 5 sizes, sum sizes)

main = do
  f <- B.readFile "SCC.txt"
  let edges = map (map ((\(Just (x,_)) -> x) . B.readInt) . B.words) $ B.lines f
      n = 875714
  putStr "Reading data... n = "
  print n
  a <- newArray (1,n) [] :: IO (IOArray Int [Int])
  ra <- newArray (1,n) [] :: IO (IOArray Int [Int])

  putStrLn "Constructing graphs..."
  mapM_ (\[v,w] -> do 
            readArray a v >>= writeArray a v . (w:)
            readArray ra w >>= writeArray ra w . (v:)) edges
  
  kosaraju n a ra
