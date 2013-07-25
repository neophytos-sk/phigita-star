CPPFLAGS = -g -Wall -Woverloaded-virtual -Wtraditional -Wpointer-arith -Wcast-qual -Wredundant-decls

CONFIGFLAGS=  -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_STDINT_H=1 -DSIZEOF_UNSIGNED_SHORT_INT=2 -DSIZEOF_UNSIGNED_LONG_INT=8 -DHAVE_STRTOL=1 -DHAVE_ICONV=1 -DHAVE_NTOHS=1 -DINTERNAL_ICONV_TYPE_UCS2=1

all: writeWStringTypes

writeWStringTypes: writeWStringTypes.cc
	g++ $(CONFIGFLAGS) writeWStringTypes.cc -o writeWStringTypes

clean: 
	rm -f writeWStringTypes

mrproper: clean
	rm -f Makefile

