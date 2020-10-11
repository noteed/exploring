# Exploring Another World

I'm trying to explore how is implemented Another World.

- [Eric Chahi's pag](http://www.anotherworld.fr/anotherworld_uk/another_world.htm)
- [Code review by Fabien Sanglard](https://fabiensanglard.net/anotherWorld_code_review/)
- [Code of the above review](https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter)
- ["The polygons of" series](https://fabiensanglard.net/another_world_polygons/)

It seems the data of the PC version can be downloaded
[here](https://www.abandonware-france.org/ltf_abandon/ltf_jeu.php?id=68).


## Current state

I have a small script that reads the `MEMLIST.BIN` files:

```
$ scripts/build.sh && bin/exploring 
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
