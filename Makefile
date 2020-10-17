ALL: bin/exploring exploring.db

bin/exploring: bin/exploring.hs
	scripts/build.sh

exploring-memlist.sql: bin/exploring
	bin/exploring sql-memlist > $@

exploring.db: exploring-schema.sql exploring-memlist.sql
	rm -f $@
	sqlite3 $@ < exploring-schema.sql
	sqlite3 $@ < exploring-memlist.sql
