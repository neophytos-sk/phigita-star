#
# Targets.
#
#

mainobjs := src/main.o src/md5.o src/library.o src/db.o src/message.o src/mailbox.o src/spam.o src/tests.o

$(package): $(mainobjs)
	$(CC) $(CFLAGS) -o $@ $(mainobjs) $(LIBS)

$(package)-static: $(mainobjs)
	$(CC) $(CFLAGS) -static -o $@ $(mainobjs) $(LIBS)

# EOF
