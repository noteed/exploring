{-# LANGUAGE RecordWildCards #-}
module Main where

import Codec.Picture (generateImage, writePng, PixelRGB8(PixelRGB8))
import Data.Binary
import Data.Binary.Get
import Data.Bits
import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as BL
import Data.List (intersperse)
import System.Environment (getArgs)
import System.IO (hClose, hSeek, openFile, IOMode(ReadMode), SeekMode(AbsoluteSeek))
import Text.Printf (printf)


--------------------------------------------------------------------------------
main :: IO ()
main = do
  args <- getArgs
  case args of
    ["sql-memlist"] -> do
      -- Generate an SQL representqtion of MEMLIST.BIN.
      entries <- readMemEntries "another-world/MEMLIST.BIN"
      putStrLn "-- Generated by bin/exploring sql-memlist."
      putStrLn "INSERT INTO memlist (\
        \state, type, packed_size, size, rank_num, bank_id, bank_offset) VALUES"
      mapM_ putStr (intersperse ",\n" (map toSQLTuple entries))
      putStrLn ";"

    ["read-bank", bankId, bankOffset, packedSize] -> do
      -- For instance to read the first pallete, which has also the smallest
      -- packed size:
      -- read-bank 1 95176 836
      s <- readBank (read bankId) (read bankOffset) (read packedSize)
      B.putStr s

    ["write-palette", n] -> do
      -- Write the ith palette from unpacked.bin to a .png file.
      let i = read n
      colors <- readColors "unpacked.bin"
      -- Skip i palettes, and each color will cover 20 pixels.
      let f x y = (drop (i * 16) colors) !! (x `div` 20)
          img = generateImage f 320 240
      writePng (printf "images/palette-%02d.png" i) img

    _ -> do
      -- More-or-less confirm we can read MEMLIST.BIN.
      putStrLn "Exploring Another World..."
      putStrLn "Reading entries from MEMLIST.BIN..."
      entries <- readMemEntries "another-world/MEMLIST.BIN"
      putStrLn ("Read " ++ show (length entries) ++ " entries.")
      putStrLn ("All but the last entry have a NotNeeded state: " ++
        show (all ((== MemEntryNotNeeded) . meState) (init entries)))
      putStrLn ("The last entry has a LastEntry state: " ++
        show (((== MemEntryLastEntry) . meState . last) entries))

toSQLTuple MemEntry{..} = concat
  [ "  (\""
  , drop 8 (show meState) ++ "\", \""
  , drop 12 (show meType) ++ "\", "
  , show mePackedSize ++ ", "
  , show meSize ++ ", "
  , show meRankNum ++ ", "
  , show meBankId ++ ", "
  , show meBankOffset ++ ")"
  ]


--------------------------------------------------------------------------------
readBank :: Int -> Int -> Int -> IO B.ByteString
readBank bankId bankOffset packedSize = do
  let filename = "another-world/BANK" ++ printf "%02x" bankId
  handle <- openFile filename ReadMode
  hSeek handle AbsoluteSeek (fromIntegral bankOffset)
  s <- B.hGet handle packedSize
  hClose handle
  if B.length s < packedSize
    then error "Can't read bank."
    else return s


--------------------------------------------------------------------------------
-- Data deserialization.
-- Note that data are in big-endian format (similar to Atari and Amiga CPUs).

-- This struct is described at, and populated at:
-- https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/resource.h#L34-L48
-- -- https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/resource.cpp#L85-L96
data MemEntry = MemEntry
  { meState      :: MemEntryState
  , meType       :: ResourceType
  , meBufPtr     :: !Word8  -- ^ Initialized to zero in the above repository.
  , meUnused0    :: !Word16 -- ^ This one is skipped in the above repository.
  , meUnused1    :: !Word16
  , meRankNum    :: !Word8  -- ^ All zero, except the last one which is 255.
  , meBankId     :: !Word8  -- ^ Between 1 and 13 incl. except last one (255).
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
  deriving (Eq, Show)

data ResourceType =
    ResourceTypeSound     -- ^ 0
  | ResourceTypeMusic     -- ^ 1
  | ResourceTypePolyAnim  -- ^ 2
  | ResourceTypePalette   -- ^ 3
  | ResourceTypeByteCode  -- ^ 4
  | ResourceTypeCinematic -- ^ 5
  | ResourceTypeUnknown   -- ^ 6
  | ResourceTypeLastEntry -- ^ 255
  deriving (Eq, Show)


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
  meState <- getMemEntryState
  meType <- getResourceType
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

getMemEntryState :: Get MemEntryState
getMemEntryState = do
  t <- getWord8
  case t of
    0 -> return MemEntryNotNeeded
    1 -> return MemEntryLoaded
    2 -> return MemEntryLoadMe
    255 -> return MemEntryLastEntry
    _ -> error ("getMemEntryState: unexpected word8.")

getResourceType :: Get ResourceType
getResourceType = do
  t <- getWord8
  case t of
    0 -> return ResourceTypeSound
    1 -> return ResourceTypeMusic
    2 -> return ResourceTypePolyAnim
    3 -> return ResourceTypePalette
    4 -> return ResourceTypeByteCode
    5 -> return ResourceTypeCinematic
    6 -> return ResourceTypeUnknown
    255 -> return ResourceTypeLastEntry


--------------------------------------------------------------------------------
readColors :: String -> IO [PixelRGB8]
readColors fn = do
  input <- BL.readFile fn
  return (runGet getColors input)

getColors :: Get [PixelRGB8]
getColors = do
  empty <- isEmpty
  if empty
    then return []
    else do
      c <- getColor
      cs <- getColors
      return (c : cs)

-- The bit manipulation to convert from 2-bytes 565 representation to
-- RGB8 is from Fabien's `sysImplementation.cpp`.
getColor :: Get PixelRGB8
getColor = do
  byte1 <- getWord8
  byte2 <- getWord8
  let i = byte1 .&. 0x0F
      j = byte2 .&. 0xF0
      k = byte2 .&. 0x0F
      r = ((shiftL i 2) .|. (shiftR i 2)) `shiftL` 2
      g = ((shiftR j 2) .|. (shiftR j 6)) `shiftL` 2
      b = ((shiftR k 2) .|. (shiftL k 2)) `shiftL` 2
  return (PixelRGB8 r g b)
