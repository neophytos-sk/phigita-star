#
# Compilation rules.
#
#

.SUFFIXES: .c .d .o

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

.c.d:
	sh $(srcdir)/autoconf/scripts/depend.sh \
	   $(CC) $< $(<:%.c=%) $(srcdir) $(CFLAGS) $(CPPFLAGS) > $@

doc/quickref.txt: doc/quickref.1
	man doc/quickref.1 | col -b | cat -s > doc/quickref.txt         || :
	chmod 644 doc/quickref.txt                                      || :

