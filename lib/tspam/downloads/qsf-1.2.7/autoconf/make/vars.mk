#
# Variables for Make.
#

srcdir = @srcdir@

prefix = @prefix@
exec_prefix = @exec_prefix@
bindir = @bindir@
infodir = @infodir@
mandir = @mandir@
etcdir = @prefix@/etc
datadir = @datadir@
sbindir = @sbindir@

VPATH = $(srcdir)

@SET_MAKE@
SHELL = /bin/sh
CC = @CC@
LD = @LD@
DO_GZIP = @DO_GZIP@
INSTALL = @INSTALL@
INSTALL_DATA = @INSTALL_DATA@
UNINSTALL = rm -f

LDFLAGS = -r
DEFS = @DEFS@
CFLAGS = @CFLAGS@
CPPFLAGS = @CPPFLAGS@ -I$(srcdir)/src/include -Isrc/include $(DEFS)
LIBS = @LDFLAGS@ @LIBS@

testdb := /tmp/@PACKAGE@test.db
testfile := /tmp/@PACKAGE@test.txt
testbackends := @BACKENDS@

alltarg = @PACKAGE@

# EOF
