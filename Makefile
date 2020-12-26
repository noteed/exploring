ALL: bin/exploring exploring.db unpack/unpack scripts/unpack-all.sh

bin/exploring: bin/exploring.hs
	scripts/build.sh

exploring-memlist.sql: bin/exploring
	bin/exploring sql-memlist > $@

exploring.db: exploring-schema.sql exploring-memlist.sql exploring-parts.sql
	rm -f $@
	sqlite3 $@ < exploring-schema.sql
	sqlite3 $@ < exploring-memlist.sql
	sqlite3 $@ < exploring-parts.sql

unpack/unpack: unpack/unpack.cpp
	g++ -o $@ $<

scripts/unpack-all.sh: exploring.db
	sqlite3 exploring.db \
	  'select printf("unpack/unpack %03d %2d %6d %5d %5d", id, bank_id, bank_offset, packed_size, size) from memlist' > $@
