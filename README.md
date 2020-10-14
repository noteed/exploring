# Exploring Another World

I'm trying to explore how is implemented Another World.

It all started yesterday (2020-10-11) when I finally, after a long time, played
again with graphics prograning in Haskell, more specifically with SDL2, and I
started the `noteed/loading` repository. Then this night, I had some trouble
sleeping and started to read about Another World. In particular, the Wikipedia
page in French talks about a virtual machine running multiple threads. This got
me curious and I wanted to read more. I found the resources linked below.


## Resources

- [Eric Chahi's pag](http://www.anotherworld.fr/anotherworld_uk/another_world.htm)
- [Code review by Fabien Sanglard](https://fabiensanglard.net/anotherWorld_code_review/)
- [Code of the above review](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter)
- ["The polygons of" series](https://fabiensanglard.net/another_world_polygons/)

It seems the data of the PC version can be downloaded
[here](https://www.abandonware-france.org/ltf_abandon/ltf_jeu.php?id=68).


## Current state

I have a small script that reads the `MEMLIST.BIN` files:

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
data.


## Notes

There are 13 `BANK` files, from `BANK01` to `BANK0D`. Bank IDs in `MEMLIST.BIN`
are numeric, thus ranging from 1 to 13. A given bank can contain multiple
resource types. For instance the bank 9 contains resource types `Palette`,
`ByteCode`, and `Cinematic`:

```
$ sqlite3 exploring.db 'SELECT type FROM memlist WHERE bank_id=9'
Palette
ByteCode
Cinematic
```

The first resouce in each bank starts at offset 0. There are an "empty"
resource (its size is zero), and a non-empty one at offset 0 in bank 1.

There a multiple resources whose size are zero; three of them have the same
bank ID and offset: 8 and 115980.
