# Automatically generated module linking rules
#
# Creation time: Tue Aug 28 14:27:40 BST 2007

src/db.o:  src/db/btree.o src/db/gdbm.o src/db/list.o src/db/main.o src/db/mysql.o src/db/obtree.o src/db/sqlite.o
	$(LD) $(LDFLAGS) -o $@  src/db/btree.o src/db/gdbm.o src/db/list.o src/db/main.o src/db/mysql.o src/db/obtree.o src/db/sqlite.o

src/main.o:  src/main/help.o src/main/log.o src/main/main.o src/main/options.o src/main/tick.o src/main/version.o
	$(LD) $(LDFLAGS) -o $@  src/main/help.o src/main/log.o src/main/main.o src/main/options.o src/main/tick.o src/main/version.o

src/spam.o:  src/spam/alloc.o src/spam/allowlist.o src/spam/benchmark.o src/spam/check.o src/spam/cksum.o src/spam/db.o src/spam/dump.o src/spam/merge.o src/spam/plaintext.o src/spam/prune.o src/spam/token.o src/spam/train.o src/spam/update.o
	$(LD) $(LDFLAGS) -o $@  src/spam/alloc.o src/spam/allowlist.o src/spam/benchmark.o src/spam/check.o src/spam/cksum.o src/spam/db.o src/spam/dump.o src/spam/merge.o src/spam/plaintext.o src/spam/prune.o src/spam/token.o src/spam/train.o src/spam/update.o

src/message.o:  src/message/alloc.o src/message/base64.o src/message/dump.o src/message/header.o src/message/parse.o src/message/qp.o src/message/read.o src/message/rfc2047.o
	$(LD) $(LDFLAGS) -o $@  src/message/alloc.o src/message/base64.o src/message/dump.o src/message/header.o src/message/parse.o src/message/qp.o src/message/read.o src/message/rfc2047.o

src/tests.o:  src/tests/attached_files.o src/tests/gibberish.o src/tests/gtube.o src/tests/html.o src/tests/imgcount.o src/tests/main.o src/tests/urls.o
	$(LD) $(LDFLAGS) -o $@  src/tests/attached_files.o src/tests/gibberish.o src/tests/gtube.o src/tests/html.o src/tests/imgcount.o src/tests/main.o src/tests/urls.o

src/mailbox.o:  src/mailbox/alloc.o src/mailbox/count.o src/mailbox/scan.o src/mailbox/select.o
	$(LD) $(LDFLAGS) -o $@  src/mailbox/alloc.o src/mailbox/count.o src/mailbox/scan.o src/mailbox/select.o


