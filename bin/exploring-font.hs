-- | This is a small script to confirm my understanding of the `_font` variable in the
-- staticres.cpp file, together with the `drawChar()` function in `video.cpp`.
-- See the README for some notes.
module Main where

import Data.Binary (Word8)
import Data.Bits (testBit)


--------------------------------------------------------------------------------
-- There are 96 * 8 entries in the `font` list below, i.e. 96 characters.
-- Each character is described by 8 byte, i.e. one line of source code in this
-- file. Thus a character is made ox 8x8 pixels.
main :: IO ()
main = mapM_ (putStr . showCharacter . (*8)) [0..95]


--------------------------------------------------------------------------------
-- This is a copy of staticres.cpp's _font, 8 bytes per line (instead of 16).
-- This is a subset of the ASCII code, with some characters replaced.
font :: [Word8]
font = [
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, -- blank
  0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x10, 0x00, -- !
  0x28, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, -- "
  0x00, 0x24, 0x7E, 0x24, 0x24, 0x7E, 0x24, 0x00, -- #
  0x08, 0x3E, 0x48, 0x3C, 0x12, 0x7C, 0x10, 0x00, -- $
  0x42, 0xA4, 0x48, 0x10, 0x24, 0x4A, 0x84, 0x00, -- %
  0x60, 0x90, 0x90, 0x70, 0x8A, 0x84, 0x7A, 0x00, -- &
  0x08, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, -- '
  0x06, 0x08, 0x10, 0x10, 0x10, 0x08, 0x06, 0x00, -- (
  0xC0, 0x20, 0x10, 0x10, 0x10, 0x20, 0xC0, 0x00, -- )
  0x00, 0x44, 0x28, 0x10, 0x28, 0x44, 0x00, 0x00, -- *
  0x00, 0x10, 0x10, 0x7C, 0x10, 0x10, 0x00, 0x00, -- +
  0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x10, 0x20, -- ,
  0x00, 0x00, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x00, -- -
  0x00, 0x00, 0x00, 0x00, 0x10, 0x28, 0x10, 0x00, -- .
  0x00, 0x04, 0x08, 0x10, 0x20, 0x40, 0x00, 0x00, -- /
  0x78, 0x84, 0x8C, 0x94, 0xA4, 0xC4, 0x78, 0x00, -- 0
  0x10, 0x30, 0x50, 0x10, 0x10, 0x10, 0x7C, 0x00, -- 1
  0x78, 0x84, 0x04, 0x08, 0x30, 0x40, 0xFC, 0x00, -- 2
  0x78, 0x84, 0x04, 0x38, 0x04, 0x84, 0x78, 0x00, -- 3
  0x08, 0x18, 0x28, 0x48, 0xFC, 0x08, 0x08, 0x00, -- 4
  0xFC, 0x80, 0xF8, 0x04, 0x04, 0x84, 0x78, 0x00, -- 5
  0x38, 0x40, 0x80, 0xF8, 0x84, 0x84, 0x78, 0x00, -- 6
  0xFC, 0x04, 0x04, 0x08, 0x10, 0x20, 0x40, 0x00, -- 7
  0x78, 0x84, 0x84, 0x78, 0x84, 0x84, 0x78, 0x00, -- 8
  0x78, 0x84, 0x84, 0x7C, 0x04, 0x08, 0x70, 0x00, -- 9
  0x00, 0x18, 0x18, 0x00, 0x00, 0x18, 0x18, 0x00, -- :
  0x00, 0x00, 0x18, 0x18, 0x00, 0x10, 0x10, 0x60, -- ;
  0x04, 0x08, 0x10, 0x20, 0x10, 0x08, 0x04, 0x00, -- <
  0x00, 0x00, 0xFE, 0x00, 0x00, 0xFE, 0x00, 0x00, -- =
  0x20, 0x10, 0x08, 0x04, 0x08, 0x10, 0x20, 0x00, -- >
  0x7C, 0x82, 0x02, 0x0C, 0x10, 0x00, 0x10, 0x00, -- ?
  0x30, 0x18, 0x0C, 0x0C, 0x0C, 0x18, 0x30, 0x00, -- )
  0x78, 0x84, 0x84, 0xFC, 0x84, 0x84, 0x84, 0x00, -- A
  0xF8, 0x84, 0x84, 0xF8, 0x84, 0x84, 0xF8, 0x00, -- B
  0x78, 0x84, 0x80, 0x80, 0x80, 0x84, 0x78, 0x00, -- C
  0xF8, 0x84, 0x84, 0x84, 0x84, 0x84, 0xF8, 0x00, -- D
  0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x7C, 0x00, -- E
  0xFC, 0x80, 0x80, 0xF0, 0x80, 0x80, 0x80, 0x00, -- F
  0x7C, 0x80, 0x80, 0x8C, 0x84, 0x84, 0x7C, 0x00, -- G
  0x84, 0x84, 0x84, 0xFC, 0x84, 0x84, 0x84, 0x00, -- H
  0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x7C, 0x00, -- I
  0x04, 0x04, 0x04, 0x04, 0x84, 0x84, 0x78, 0x00, -- J
  0x8C, 0x90, 0xA0, 0xE0, 0x90, 0x88, 0x84, 0x00, -- K
  0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xFC, 0x00, -- L
  0x82, 0xC6, 0xAA, 0x92, 0x82, 0x82, 0x82, 0x00, -- M
  0x84, 0xC4, 0xA4, 0x94, 0x8C, 0x84, 0x84, 0x00, -- N
  0x78, 0x84, 0x84, 0x84, 0x84, 0x84, 0x78, 0x00, -- O
  0xF8, 0x84, 0x84, 0xF8, 0x80, 0x80, 0x80, 0x00, -- P
  0x78, 0x84, 0x84, 0x84, 0x84, 0x8C, 0x7C, 0x03, -- Q
  0xF8, 0x84, 0x84, 0xF8, 0x90, 0x88, 0x84, 0x00, -- R
  0x78, 0x84, 0x80, 0x78, 0x04, 0x84, 0x78, 0x00, -- S
  0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, -- T
  0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x78, 0x00, -- U
  0x84, 0x84, 0x84, 0x84, 0x84, 0x48, 0x30, 0x00, -- V
  0x82, 0x82, 0x82, 0x82, 0x92, 0xAA, 0xC6, 0x00, -- W
  0x82, 0x44, 0x28, 0x10, 0x28, 0x44, 0x82, 0x00, -- X
  0x82, 0x44, 0x28, 0x10, 0x10, 0x10, 0x10, 0x00, -- Y
  0xFC, 0x04, 0x08, 0x10, 0x20, 0x40, 0xFC, 0x00, -- Z
  0x3C, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3C, 0x00, -- [
  0x3C, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3C, 0x00, -- [
  0x3C, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3C, 0x00, -- [
  0x3C, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3C, 0x00, -- ]
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE, -- _
  0x3C, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3C, 0x00, -- [
  0x00, 0x00, 0x38, 0x04, 0x3C, 0x44, 0x3C, 0x00, -- a
  0x40, 0x40, 0x78, 0x44, 0x44, 0x44, 0x78, 0x00, -- b
  0x00, 0x00, 0x3C, 0x40, 0x40, 0x40, 0x3C, 0x00, -- c
  0x04, 0x04, 0x3C, 0x44, 0x44, 0x44, 0x3C, 0x00, -- d
  0x00, 0x00, 0x38, 0x44, 0x7C, 0x40, 0x3C, 0x00, -- e
  0x38, 0x44, 0x40, 0x60, 0x40, 0x40, 0x40, 0x00, -- f
  0x00, 0x00, 0x3C, 0x44, 0x44, 0x3C, 0x04, 0x78, -- g
  0x40, 0x40, 0x58, 0x64, 0x44, 0x44, 0x44, 0x00, -- h
  0x10, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, -- i
  0x02, 0x00, 0x02, 0x02, 0x02, 0x02, 0x42, 0x3C, -- j
  0x40, 0x40, 0x46, 0x48, 0x70, 0x48, 0x46, 0x00, -- k
  0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, -- l
  0x00, 0x00, 0xEC, 0x92, 0x92, 0x92, 0x92, 0x00, -- m
  0x00, 0x00, 0x78, 0x44, 0x44, 0x44, 0x44, 0x00, -- n
  0x00, 0x00, 0x38, 0x44, 0x44, 0x44, 0x38, 0x00, -- o
  0x00, 0x00, 0x78, 0x44, 0x44, 0x78, 0x40, 0x40, -- p
  0x00, 0x00, 0x3C, 0x44, 0x44, 0x3C, 0x04, 0x04, -- q
  0x00, 0x00, 0x4C, 0x70, 0x40, 0x40, 0x40, 0x00, -- r
  0x00, 0x00, 0x3C, 0x40, 0x38, 0x04, 0x78, 0x00, -- s
  0x10, 0x10, 0x3C, 0x10, 0x10, 0x10, 0x0C, 0x00, -- t
  0x00, 0x00, 0x44, 0x44, 0x44, 0x44, 0x78, 0x00, -- u
  0x00, 0x00, 0x44, 0x44, 0x44, 0x28, 0x10, 0x00, -- v
  0x00, 0x00, 0x82, 0x82, 0x92, 0xAA, 0xC6, 0x00, -- w
  0x00, 0x00, 0x44, 0x28, 0x10, 0x28, 0x44, 0x00, -- x
  0x00, 0x00, 0x42, 0x22, 0x24, 0x18, 0x08, 0x30, -- y
  0x00, 0x00, 0x7C, 0x08, 0x10, 0x20, 0x7C, 0x00, -- z
  0x60, 0x90, 0x20, 0x40, 0xF0, 0x00, 0x00, 0x00, -- 2 superscript
  0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0x00, -- black
  0x38, 0x44, 0xBA, 0xA2, 0xBA, 0x44, 0x38, 0x00, -- copyright
  0x38, 0x44, 0x82, 0x82, 0x44, 0x28, 0xEE, 0x00, -- omega
  0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA ] -- black

-- | Given 1 Word8, display an x for each "on" bit.
showCharacterLine byte =
  map ((\b -> if b then 'x' else ' ') . testBit byte) [7,6..0]

showCharacter n =
  concatMap ((++ "\n") . showCharacterLine . (font !!)) [n..n+7]