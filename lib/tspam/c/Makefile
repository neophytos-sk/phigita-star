# Makefile for bmf

BINDIR=../bin
MANDIR=../man

VERSION=0.9.4

CC=gcc
#CFLAGS=-DNDEBUG -D_UNIX -D_LINUX -Wall -DHAVE_LIBDB
CFLAGS=-DNDEBUG -D_UNIX -D_LINUX -Wall
#LDFLAGS= -ldb
LDFLAGS=
SYSLIBS=

# For creating rpm packages
RPMROOT=/usr/src/rpm
RPM = rpm
RPMFLAGS = -ba
ARCH=`arch|sed 's/i[4-9]86/i386/'`

all: bmf lex

lex:
	$(CC) -o $@ -DUNIT_TEST lex.c dbg.c str.c

#bmf: bmf.o filt.o dbmysql.o dbdb.o dbtext.o dbh.o lex.o vec.o str.o dbg.o
#	$(CC) -o $@ bmf.o filt.o dbmysql.o dbdb.o dbtext.o dbh.o lex.o vec.o str.o dbg.o $(LDFLAGS) $(SYSLIBS)
bmf: bmf.o filt.o dbtext.o dbh.o lex.o vec.o str.o dbg.o
	$(CC) -o $@ bmf.o filt.o dbtext.o dbh.o lex.o vec.o str.o dbg.o $(LDFLAGS) $(SYSLIBS)

bmf.o: bmf.c
	$(CC) $(CFLAGS) -DPACKAGE=\"bmf\" -DVERSION=\"$(VERSION)\" -c $<

#bmfconv: bmfconv.o dbmysql.o dbdb.o dbtext.o dbh.o vec.o str.o dbg.o
#	$(CC) -o $@ bmfconv.o dbmysql.o dbdb.o dbtext.o dbh.o vec.o str.o dbg.o $(LDFLAGS) $(SYSLIBS)
bmfconv: bmfconv.o dbtext.o dbh.o vec.o str.o dbg.o
	$(CC) -o $@ bmfconv.o dbtext.o dbh.o vec.o str.o dbg.o $(LDFLAGS) $(SYSLIBS)

bmfconv.o: bmfconv.c
	$(CC) $(CFLAGS) -DPACKAGE=\"bmfconv\" -DVERSION=\"$(VERSION)\" -c $<

install: checkroot bmf bmf.1 bmfconv bmfconv.1
	[ -d $(DESTDIR)$(BINDIR) ] || mkdir -p $(DESTDIR)$(BINDIR)
	[ -d $(DESTDIR)$(MANDIR)/man1 ] || mkdir -p $(DESTDIR)$(MANDIR)/man1
	cp bmf $(DESTDIR)$(BINDIR)
	cp bmf.1 $(DESTDIR)$(MANDIR)/man1
	cp bmfconv $(DESTDIR)$(BINDIR)
	cp bmfconv.1 $(DESTDIR)$(MANDIR)/man1

uninstall: checkroot
	rm -f $(DESTDIR)$(BINDIR)/bmf
	rm -f $(DESTDIR)$(MANDIR)/man1/bmf.1
	rm -f $(DESTDIR)$(BINDIR)/bmfconv
	rm -f $(DESTDIR)$(MANDIR)/man1/bmfconv.1

clean:
	rm -f core *.o bmf bmfconv lex

distclean: clean
	rm -f Makefile

dist: tarball rpmpkg debpkg

tarball: distclean
	(cd ..; \
	 cp -ar bmf bmf-$(VERSION); \
	 tar czvf bmf-$(VERSION).tar.gz `find bmf-$(VERSION) -type f | egrep -v "CVS|debian"`; \
	 rm -rf bmf-$(VERSION); \
	 cd $(PWD))

debpkg: checkroot
	debian/rules binary
	rm -rf debian/tmp

rpmpkg: checkroot
	(mkdir -p $(RPMROOT); \
	 mkdir -p $(RPMROOT)/SOURCES; \
	 mkdir -p $(RPMROOT)/SPECS; \
	 mkdir -p $(RPMROOT)/RPMS; \
	 mkdir -p $(RPMROOT)/SRPMS; \
	 cp ../bmf-$(VERSION).tar.gz $(RPMROOT)/SOURCES; \
	 cat bmf.spec.in | sed 's/VERSION/$(VERSION)/' > $(RPMROOT)/SPECS/bmf.spec; \
	 cd $(RPMROOT)/SPECS; \
	 $(RPM) $(RPMFLAGS) bmf.spec; \
	 cp $(RPMROOT)/RPMS/$(ARCH)/bmf-$(VERSION)-*.rpm $(PWD)/..; \
	 cp $(RPMROOT)/SRPMS/bmf-$(VERSION)-*.src.rpm $(PWD)/..; \
	 cd $(PWD))

checkroot:
	[ "`whoami`" = root ] || (echo Need root; exit 1)
