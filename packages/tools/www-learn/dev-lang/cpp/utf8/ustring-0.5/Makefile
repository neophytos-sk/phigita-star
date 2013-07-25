# Generated automatically from Makefile.in by configure.

CPPFLAGS = -g -Wall -Woverloaded-virtual -Wtraditional -Wpointer-arith -Wcast-qual -Wredundant-decls

BUILDBASE= buildData.o

UNIBASE= WString.o UnicodeData.o WRegExp.o unicodedata-gen.o

RANLIB= ranlib
AR= ar
CONFIGFLAGS= -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_STDINT_H=1 -DSIZEOF_UNSIGNED_SHORT_INT=2 -DSIZEOF_UNSIGNED_LONG_INT=8 -DHAVE_STRTOL=1 -DHAVE_ICONV=1 -DHAVE_NTOHS=1 -DINTERNAL_ICONV_TYPE_UCS2=1
srcdir = .
top_srcdir = .

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
libdir = ${exec_prefix}/lib

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL} $(AM_INSTALL_PROGRAM_FLAGS)
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL}

includedirs = /usr/include/ustring

%.o : %.cc %.h
	g++ $(CPPFLAGS) -c $< 

all: writeconfig buildData libustring.a utest


writeconfig: tests/writeWStringTypes.cc
	$(MAKE) -C tests ; tests/writeWStringTypes >WStringTypes.h

buildData: $(BUILDBASE)
	g++ -g $(BUILDBASE) -o buildData

unicodedata-gen.cc: buildData UnicodeData-Latest.txt
	buildData ./UnicodeData-Latest.txt

libustring.a:  unicodedata-gen.cc $(UNIBASE)
	$(AR) cru libustring.a $(UNIBASE)
	$(RANLIB) libustring.a

utest: libustring.a utest.cc
	g++ $(CPPFLAGS) utest.cc -o utest -L. -lustring

install: all
	$(INSTALL) -d $(includedirs)
	$(INSTALL) *.h $(includedirs)
	$(INSTALL) libustring.a $(libdir)

clean :
	rm -f unicodedata-gen.h unicodedata-gen.cc
	rm -f $(BUILDBASE) $(UNIBASE) buildData utest libustring.a

mrproper: clean
	rm -f *~ core config.log config.cache config.status Makefile
	$(MAKE) -C tests mrproper

