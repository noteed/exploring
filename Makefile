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

scripts/unpack-all.sh:
	sqlite3 exploring.db \
	  'select printf("unpack/unpack %03d %d %d %d %d", id, bank_id, bank_offset, packed_size, size) from memlist' > $@
