# Exploring Another World

In this repository, I explore how Eric Chahi's Another World is implemented.
Another World (also called Out of This World in North America) is a computer
game released in 1991. It was initially written for the Amiga 500, and then
ported to other systems. A very interesting aspect of the software is that it
is mainly written as a virtual machine.

It all started the 2020-10-11 when I finally, after a long time, decided to
play again with graphics programming in Haskell. (This probably was itself
prompted by turning on my PlayStation 3, running Grid, whose first saved game
was from 2010.) Then the night after, I had some trouble sleeping and started
to read about Another World. In particular, the Wikipedia page (at least the
one [in
French](https://fr.wikipedia.org/wiki/Another_World_(jeu_vid%C3%A9o)#Aspect_technique))
talks about a game engine written as a virtual machine running multiple light
threads. This got me curious and I wanted to read more. I started with the
resources linked below, then wrote some code to explore the game data.


## Resources

- [Eric Chahi's
  page](http://www.anotherworld.fr/anotherworld_uk/another_world.htm)
- [Code review by Fabien
  Sanglard](https://fabiensanglard.net/anotherWorld_code_review/)
- [Source code of the above
  review](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter)
- ["The polygons of"
  series](https://fabiensanglard.net/another_world_polygons/)
- [Gregory Montoir's raw(gl)](https://github.com/cyxx)

It seems the data of the PC version can be downloaded
[here](https://www.abandonware-france.org/ltf_abandon/ltf_jeu.php?id=68).

The original English Amiga version, with the protection screen disabled, are
available in the Retro Presskit here: [the Digital Lounge
presskit](http://www.thedigitalounge.com/presskit.html). The two `.adf` files
are the same as the one present in the 20th anniversary edition available on
Steam.

One of the most interesting resources is actually a commentary within the [main
file](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/8afc0f7d7d47f7700ad2e7d1cad33200ad29b17f/src/main.cpp)
in the above repository. It links to a fan site on Google Sites, which seems
down but is still available on the [Waybach
Machine](https://web.archive.org/web/20141013135226/https://sites.google.com/site/interlinkknight/anotherworld).

Some code is more readable in the original repository than in Fabien's. For
instance the code to decompress resources:
[Fabien's](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/bank.cpp)
v. [Gregory's](https://github.com/cyxx/rawgl/blob/master/unpack.cpp).

The commit comment in Gregory's seems to say the unpacking code is similar to
this one: https://git.gatekiller.co.uk/games/flashback.
[Indeed](https://git.gatekiller.co.uk/games/flashback/src/branch/master/unpack.cpp).

There is an interesting `docs/` directory in the `rawgl` repository.


## Current state

I have a small Haskell script that reads the `MEMLIST.BIN` files:

```
$ make && bin/exploring
[1 of 1] Compiling Main             ( bin/exploring.hs, bin/exploring.o )
Linking bin/exploring ...
Exploring Another World...
Reading entries from MEMLIST.BIN...
Read 147 entries.
All but the last entry have a NotNeeded state: True
The last entry has a LastEntry state: True
```

Note: the above code review talks about 146 "resources" and 148 "bank files".
I guess the second number is a mistake...

I also can generate some SQL `INSERT`s to represent the content of
`MEMLIST.BIN` file as a SQLite database.

```
$ make exploring.db && sqlite3 exploring.db \
    'SELECT sum(size) FROM memlist WHERE type != "LastEntry"'
1730258
```

Having such a relational database to query is really a nice way to explore the
data, as can be seen in some notes below.


## Parts

The game is organized in 9 "parts", which include e.g. the "Suspended jail",
but also the protection and password screens.

In both
[Fabien's](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/6093bbca11b046a64557354eb4c237b0318f4ec7/src/parts.cpp)
and
[Gregory's](https://github.com/cyxx/rawgl/blob/8b4c255453229bca15df715961554f85adec8eb5/resource.cpp#L566-L577)
versions, the list of game parts is hard-coded, and for each part, the resource
IDs are known: palette, virtual machine instructions, and graphics (both
cinematics and gameplay).

I have also created [hard-coded data](exploring-parts.sql) for SQLite:

```
$ sqlite3 -init sqliterc.txt exploring.db 'select * from parts'
-- Loading resources from sqliterc.txt
id          palette     bytecode    cinematics  characters  comment
----------  ----------  ----------  ----------  ----------  ------------------
16000       20          21          22          0           protection screens
16001       23          24          25          0           introduction cinem
16002       26          27          28          17          water
16003       29          30          31          17          suspended jail
16004       32          33          34          17          cite
16005       35          36          37          0           battlechar cinemat
16006       38          39          40          17          luxe
16007       41          42          43          17          final
16008       125         126         127         0           password screen
16009       125         126         127         0           password screen
```

Note that there are 10 lines but I count the last two as a single part.


## Files

The game data are placed in 13 `BANK` files, from `BANK01` to `BANK0D`.
A given bank can contain multiple resource types (palette, bytecode, ...).

Resource IDs, as given in the previous section, are indices into a file called
`MEMLIST.BIN`. Given a resource, `MEMLIST.BIN` is read by the game engine to
know where the resource data themselves (e.g. palette colors) can be found: in
which bank, at which offset.

In `MEMLIST.BIN`, the bank IDs are numeric, thus ranging from 1 to 13.


## Resources

I have written some code to parse the `MEMLIST.BIN` file and generate
equivalent SQL statements. See the [`Makefile`](Makefile).

For instance the bank 9 contains resource types `Palette`,
`Bytecode`, and `Cinematic`:

```
$ sqlite3 exploring.db 'SELECT type FROM memlist WHERE bank_id=9'
Palette
Bytecode
Cinematic
```

The first resource in each bank starts at offset 0. There are "empty" resources
(with a size of zero), and a non-empty one at offset 0 in bank 1.

There a multiple resources whose size are zero; three of them have the same
bank ID and offset: 8 and 115980.

The following numbers match the code review linked above:

```
$ sqlite3 -init sqliterc.txt exploring.db \
    'select type, count(type) as total from memlist
     group by type order by total desc'
-- Loading resources from sqliterc.txt
type        total
----------  ----------
Sound       103
PolyAnim    12
Palette     9
Cinematic   9
Bytecode    9
Music       3
Unknown     1
LastEntry   1
```

And also match the reported (packed) size here in the [source
code](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/8afc0f7d7d47f7700ad2e7d1cad33200ad29b17f/src/main.cpp#L201-L208).

When reading a resource out of a bank, the last 32 bits indicate the size of
the unpacked data (and thus should match what is found in `MEMLIST.BIN`). For
instance, the very first palette can be extracted (but not unpacked yet) with:

```
$ scripts/build.sh && bin/exploring read-bank 1 95176 836 > palette-1
$ xxd palette-1 | tail -n 1
00000340: 0000 0800
```

We see that `8 * 256 = 2048`, wich is indeed the unpacked size of any palette.


## Palettes

All resources of type `Palette` have an uncompressed size of 2048 (and their
sizes within the `BANK` files are smaller, so the palettes are all compressed).

```
$ sqlite3 -init sqliterc.txt exploring.db \
    'select id,bank_id,bank_offset,packed_size,size from memlist
     where type="Palette" order by id'
-- Loading resources from sqliterc.txt
id   bank_id  bank_offset  packed_size  size
---  -------  -----------  -----------  ----
20   1        95176        836          2048
23   1        102512       1336         2048
26   13       0            1228         2048
29   13       60108        1376         2048
32   3        0            1196         2048
35   10       0            1260         2048
38   10       30140        1312         2048
41   11       0            1220         2048
125  9        0            1268         2048
```

The comment in the [source
code](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/resource.h#L74)
says the 2048 bytes are used for a VGA palette, and an EGA palette, each 1024
bytes.

In the game, each pixel color is given by a 4-bit index into the palette (so 1
byte is enough to describe two pixels).

Within the pallete, a color is specified using 5 bits for red, 6 bits for
green, and 5 bits for blue, i.e. a 565 format, and thus takes 2 bytes.

Given 2 bytes per color, and 16 colors, a palette is only 32 bytes. This seems
to mean there is actually 32 palettes in a Palette resource.

It is possible to convert the nth palette from BANK01 with the following calls.
They expect the `unpacked.bin` files produced in the section below.
(`palette-0` is all black.)

```
$ scripts/build.sh && bin/exploring write-palette 1
$ feh images/palette-01.png
```

![Palette 1](images/palette-01.png)
![Palette 27](images/palette-27.png)

I was unsure if the code to read the palette was correct, but the second image
above seems to match the colors seen in the title screens at the start of the
game.

Only the two images above are committed in this repository. If you want to generate
some other images:

```
$ for i in `seq 0 31` ; do bin/exploring write-palette $i ; done
$ feh -Zr. images/
```


## Bytecode

The list of possible operations is mainly visible in `staticres.cpp`: there are only
27 operations visible there but some additional ones are not named.

Just like palettes, the "script" ID of each game part is given in the
hard-coded data (see the [Parts](#parts) section above). The virtual machine
implemented in the game reads one byte at a time, interpreting it. (This is
done in the `vm.cpp` file.) Each operation can read additional bytes when
executed.

Within a Bytecode resource, there is the code for multiple threads. Thread 0
starts with the first byte of the bytecode. I'm not sure yet, but I think the
other threads are spawned from other threads and don't exist statically.

I have a bytecode parser. To help validate it, I have found a
[disassembler](https://github.com/cyxx/rawgl/blob/master/tools/disasm/disasm.cpp)
in the rawgl repository. This is also helpful to give names to some operations
that don't have explicit opcodes elsewhere.

```
$ bin/exploring write-bytecode 21 | head
OpCall 4304
OpMovConst 255 2
OpSpawnThread 60 4259
OpPauseThread
OpFillVideoPage 0 7
OpSpawnThread 20 718
OpKillThread
OpKillThread
OpAddConst 99 1
OpAddConst 90 13
```

```
$ rawgl/tools/disasm/disasm resources/unpacked-021.bin | head
0000: (04) call(@10D0)
0003: (00) VAR(0xFF) = 2
0007: (08) installTask(60, @10A3)
000B: (06) yieldTask // PAUSE SCRIPT TASK
000C: (0E) fillPage(page=0, color=7)
000F: (08) installTask(20, @02CE)
0013: (11) removeTask // STOP SCRIPT TASK
0014: (11) removeTask // STOP SCRIPT TASK

0015: // func_0015
```


## Polygons

By reading how the `OpDrawPolygon` opcode is implemented in either source code,
we can learn how graphic data can be found. This simply seems to be given by an
offset into the graphic data (either cinematics or gameplay).


## Font

There is an array named `_font` in `staticres.cpp` with a hard-coded list of
bytes. Also, in `video.cpp` there is a fonction `drawChar()`. In particular
there is a line which offers a lot of clue:

```
    uint8_t *p = buf + x * 4 + y * 160;
```

The formula `x + y * stride` is typical of pixel addressing in a 1d-array. We
already know that each byte represents two pixels, which is confirmed by `*
160`: advancing to the next line (i.e. by 320 pixels) is done by advancing by
160 bytes.

Then that function uses 8 consecutives entries in `_font` for a given
character, advancing each time by 160 bytes. So I assume those 8 iterations are
done to cover 8 pixels vertically.

At each iteration, it loops 4 times horizontaly, exploiting each time 2 bits of
a `_font` entry. So I assume each `_font` entry specifies 8 pixels that should
be "on" or "off".

For each "on" pixel, 4 bits of the given color are used. When a pixel is "off",
the color already present in the target buffer is reused.

In short, the font is made from 8x8 characters, specified by 8 entries in
`_font`. This is confirmed by the `bin/exploring-font.hs` script.


## Unpack

While trying to understand `Bank::unpack` in Fabien's repository, I found that
Gregory's version in rawgl is easier to read. I looked at the code several
times on the span of three or four days. Interestingly, my understanding of it
increased each time in the first few minutes at staring at the code (as opposed
to the long minutes afterwards).

Anyway, I also found an interesting commit message in rawgl, mentionning
"ByteKiller". I first thought it was another version of similar code but it
seems it is the name of the compression software: as it was mentioned nowhere
else, this is an interesting find!

I have made a copy of rawgl's `unpack.cpp` in `unpack/` in this repository.
After adding the `READ_BE_UINT32` macro and the `warning` function, the file
compiles fine with `g++ -c unpack.cpp`. Then I added a `main` function to read
a resource from a `BANK` file:

```
$ ls unpack
unpack.cpp
$ g++ -o unpack/unpack unpack/unpack.cpp
$ unpack/unpack 020 1 95176 836 2048
$ ls -l resources/unpacked-020.bin
-rw-r--r-- 1 thu users  2048 Oct 17 14:45 resources/unpacked-020.bin
```

The arguments are the resource ID (this is just used to name the output file),
the bank ID, the offset within the BANK file, the packed size, and the unpacked
size. A helper script `scripts/unpack-all.sh` is generated with the appropriate
values (see the `Makefile` to see how).

Some of the calls are wrong, especially the last one:

```
$ sh scripts/unpack-all.sh
WARNING: Unexpected unpack size 285542123, buffer size 882!
WARNING: Unexpected unpack size 50528001, buffer size 7684!
WARNING: Unexpected unpack size 50529028, buffer size 5420!
WARNING: Unexpected unpack size 990122782, buffer size 1460!
WARNING: Unexpected unpack size 99937556, buffer size 4848!
WARNING: Unexpected unpack size 1460146100, buffer size 11880!
WARNING: Unexpected unpack size 50266370, buffer size 17500!
WARNING: Unexpected unpack size 50528001, buffer size 4886!
terminate called after throwing an instance of 'std::out_of_range'
  what():  stoi
scripts/unpack-all.sh: line 147: 29407 Aborted
(core dumped) unpack/unpack 146 255 4294967295 65535 65535
```


## Steam

Here are some information about the game files when purchasing Another World on
Steam, which is the 20th anniversary edition, released April 4th, 2013.

Below, `steam/` is a symlink to `~/.local/share/Steam/steamapps/common/Another
World`.

```
$ du -chs steam/
709M    steam/
709M    total

$ ls steam/
amd64               Bonus        game                 layout_custom.xml  steam_appid.txt
AnotherWorld        credits      hud.fsh              menubonus.bat      thumbs
AnotherWorld-amd64  cursor.bmp   hud.vsh              menubonus.sh       x86
AnotherWorld.png    default.fsh  icon.bmp             README-linux.txt   xdg-open
AnotherWorld-x86    default.vsh  layout_1024x768.xml  ressources
```

An interesting thing is that this contains files with a `.nom` extension. I saw
that extension in rawgl disassembler and in another tool which seems to be able
to read polygons out of the game files.

```
$ find steam/ -iname '*.nom'
steam/game/DAT/FINAL2011.nom
steam/game/DAT/INTRO2011.nom
steam/game/DAT/CITE2011.nom
steam/game/DAT/LUXE2011.nom
steam/game/DAT/BANK2hd.nom
steam/game/DAT/PRI2011.nom
steam/game/DAT/EAU2011.nom
steam/game/DAT/BANK2.NOM
```

Looking to other files, I noticed some that are 2048 bytes, with a `.pal`
extension. Surely those are unpacked palette resources ? I compared SHA1 sums
of my unpacked resource files and one matches a `.pal` file in steam/game/DAT:

```
90d179214abc7cae251eb880c193abf6b628468d  resources/unpacked-023.bin
90d179214abc7cae251eb880c193abf6b628468d  steam/game/DAT/FILE023.DAT
90d179214abc7cae251eb880c193abf6b628468d  steam/game/DAT/INTRO2011.pal
...
a84d3129d6119d7669eb8179459b145cc1f543b7  resources/unpacked-125.bin
a84d3129d6119d7669eb8179459b145cc1f543b7  steam/game/DAT/FILE125.DAT
```

Note that multiple files in `steam/game/DAT` have the same hashes.

There seems to be the Amiga version too:

```
$ ls steam/Bonus/rom\ Amiga/
AnotherWorld_DiskA_nologo_noprotec.adf  AnotherWorld_DiskB_nologo_noprotec.adf
```

### Playing

I set `fullscreen` to false in `~/.local/share/DotEMU/Another
World/AnotherWorldUserDef.xml`. (For Steam on my T480, which uses NixOS and
xmonad.)

When launching the game, there is a Steam menu to view some Bonus content,
which just opens the directory within a browser...

Within the game menu, it is possible to choose low or high resolution.


## TODO

- I think the `memlist` table should be renamed `resources`.
