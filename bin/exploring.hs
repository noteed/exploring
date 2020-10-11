{-# LANGUAGE RecordWildCards #-}
module Main where

import Data.Binary
import Data.Binary.Get
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as BL


--------------------------------------------------------------------------------
main :: IO ()
main = do
  putStrLn "Exploring Another World..."
  putStrLn "Reading entries from MEMLIST.BIN..."
  entries <- readMemEntries "another-world/MEMLIST.BIN"
  putStrLn ("Read " ++ show (length entries) ++ " entries.")
  putStrLn ("All but the last entry have a NotNeeded state: " ++
    show (all ((== 0) . meState) (init entries)))
  putStrLn ("The last entry has a LastEntry state: " ++
    show (((== 255) . meState . last) entries))


--------------------------------------------------------------------------------
-- This struct is described at, and populated at:
-- https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/resource.h#L34-L48
-- -- https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/resource.cpp#L85-L96
data MemEntry = MemEntry
  { meState      :: !Word8  -- ^ See MemEntryState.
  , meType       :: !Word8
  , meBufPtr     :: !Word8
  , meUnused0    :: !Word16 -- ^ This one is skipped in the above repository.
  , meUnused1    :: !Word16
  , meRankNum    :: !Word8
  , meBankId     :: !Word8
  , meBankOffset :: !Word32
  , meUnused2    :: !Word16
  , mePackedSize :: !Word16
  , meUnused3    :: !Word16
  , meSize       :: !Word16
  }

data MemEntryState =
    MemEntryNotNeeded -- ^ 0
  | MemEntryLoaded    -- ^ 1
  | MemEntryLoadMe    -- ^ 2
  | MemEntryLastEntry -- ^ 255


--------------------------------------------------------------------------------
readMemEntries :: String -> IO [MemEntry]
readMemEntries fn = do
  input <- BL.readFile fn
  return (runGet getMemEntries input)

getMemEntries :: Get [MemEntry]
getMemEntries = do
  empty <- isEmpty
  if empty
    then return []
    else do
      e <- getMemEntry
      es <- getMemEntries
      return (e : es)

getMemEntry :: Get MemEntry
getMemEntry = do
  meState <- getWord8
  meType <- getWord8
  let meBufPtr = 0
  meUnused0 <- getWord16be
  meUnused1 <- getWord16be
  meRankNum <- getWord8
  meBankId <- getWord8
  meBankOffset <- getWord32be
  meUnused2 <- getWord16be
  mePackedSize <- getWord16be
  meUnused3 <- getWord16be
  meSize <- getWord16be
  return $! MemEntry {..}
