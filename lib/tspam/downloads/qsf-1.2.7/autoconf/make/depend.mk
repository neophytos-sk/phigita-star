#
# Dependencies.
#

src/library.d src/library.o: src/library.c src/include/config.h 
src/md5.d src/md5.o: src/md5.c src/include/md5.h src/include/config.h 
src/db/obtree.d src/db/obtree.o: src/db/obtree.c src/include/config.h src/include/database.h src/include/log.h 
src/db/list.d src/db/list.o: src/db/list.c src/include/config.h src/include/database.h src/include/log.h 
src/db/main.d src/db/main.o: src/db/main.c src/include/config.h src/include/database.h 
src/db/gdbm.d src/db/gdbm.o: src/db/gdbm.c src/include/config.h src/include/database.h 
src/db/btree.d src/db/btree.o: src/db/btree.c src/include/config.h src/include/database.h src/include/log.h 
src/db/sqlite.d src/db/sqlite.o: src/db/sqlite.c src/include/config.h src/include/database.h src/include/log.h 
src/db/mysql.d src/db/mysql.o: src/db/mysql.c src/include/config.h src/include/database.h src/include/log.h 
src/main/help.d src/main/help.o: src/main/help.c src/include/config.h 
src/main/options.d src/main/options.o: src/main/options.c src/include/config.h src/include/options.h src/include/spam.h src/include/message.h src/include/log.h 
src/main/version.d src/main/version.o: src/main/version.c src/include/config.h 
src/main/main.d src/main/main.o: src/main/main.c src/include/config.h src/include/options.h src/include/message.h src/include/spam.h src/include/database.h src/include/log.h 
src/main/log.d src/main/log.o: src/main/log.c src/include/config.h src/include/log.h 
src/main/tick.d src/main/tick.o: src/main/tick.c src/include/config.h 
src/spam/update.d src/spam/update.o: src/spam/update.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/merge.d src/spam/merge.o: src/spam/merge.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/alloc.d src/spam/alloc.o: src/spam/alloc.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/train.d src/spam/train.o: src/spam/train.c src/include/config.h src/include/mailbox.h src/include/options.h src/spam/spami.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/cksum.d src/spam/cksum.o: src/spam/cksum.c src/include/config.h src/include/md5.h 
src/spam/benchmark.d src/spam/benchmark.o: src/spam/benchmark.c src/include/config.h src/include/mailbox.h src/include/options.h src/spam/spami.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/check.d src/spam/check.o: src/spam/check.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h src/include/log.h 
src/spam/plaintext.d src/spam/plaintext.o: src/spam/plaintext.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h src/include/log.h 
src/spam/dump.d src/spam/dump.o: src/spam/dump.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/token.d src/spam/token.o: src/spam/token.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/db.d src/spam/db.o: src/spam/db.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/prune.d src/spam/prune.o: src/spam/prune.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h 
src/spam/allowlist.d src/spam/allowlist.o: src/spam/allowlist.c src/include/config.h src/spam/spami.h src/include/options.h src/include/message.h src/include/database.h src/include/spam.h src/include/log.h 
src/message/parse.d src/message/parse.o: src/message/parse.c src/include/config.h src/include/message.h src/include/options.h src/include/md5.h 
src/message/alloc.d src/message/alloc.o: src/message/alloc.c src/include/config.h src/include/message.h src/include/options.h 
src/message/read.d src/message/read.o: src/message/read.c src/include/config.h src/include/message.h src/include/options.h 
src/message/rfc2047.d src/message/rfc2047.o: src/message/rfc2047.c src/include/config.h src/include/message.h src/include/options.h 
src/message/header.d src/message/header.o: src/message/header.c src/include/config.h src/include/message.h src/include/options.h 
src/message/qp.d src/message/qp.o: src/message/qp.c src/include/config.h 
src/message/dump.d src/message/dump.o: src/message/dump.c src/include/config.h src/include/message.h src/include/options.h src/include/log.h 
src/message/base64.d src/message/base64.o: src/message/base64.c src/include/config.h 
src/tests/gtube.d src/tests/gtube.o: src/tests/gtube.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h 
src/tests/main.d src/tests/main.o: src/tests/main.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h 
src/tests/imgcount.d src/tests/imgcount.o: src/tests/imgcount.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h 
src/tests/urls.d src/tests/urls.o: src/tests/urls.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h src/include/spam.h 
src/tests/gibberish.d src/tests/gibberish.o: src/tests/gibberish.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h 
src/tests/attached_files.d src/tests/attached_files.o: src/tests/attached_files.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h 
src/tests/html.d src/tests/html.o: src/tests/html.c src/include/config.h src/tests/testi.h src/include/options.h src/include/message.h src/include/spam.h 
src/mailbox/alloc.d src/mailbox/alloc.o: src/mailbox/alloc.c src/include/config.h src/include/mailbox.h src/include/options.h src/mailbox/mailboxi.h 
src/mailbox/count.d src/mailbox/count.o: src/mailbox/count.c src/include/config.h src/include/mailbox.h src/include/options.h src/mailbox/mailboxi.h 
src/mailbox/select.d src/mailbox/select.o: src/mailbox/select.c src/include/config.h src/include/mailbox.h src/include/options.h src/mailbox/mailboxi.h 
src/mailbox/scan.d src/mailbox/scan.o: src/mailbox/scan.c src/include/config.h src/include/mailbox.h src/include/options.h src/mailbox/mailboxi.h 
