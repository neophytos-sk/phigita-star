# USE gmake (GNU Make) INSTEAD OF make !!!

LIBDIR0 = /local/encap/flex-2.5.4/lib/
LEX = flex

OSTYPE = $(shell uname)

# use bison different linking flags on cygwin
ifneq (,$(findstring CYGWIN, $(OSTYPE)))
	YACC = bison -y -d
	DEFINED = -DCYGWIN -DGETOPT
	LINKFLAGS = -lfl 
endif

ifneq (,$(findstring Linux,$(OSTYPE)))
	YACC = bison -y -d
	DEFINED = -DCYGWIN -DLINUX 
	LINKFLAGS = -lfl -pthread 
	GCCV = $(shell gcc --version)
ifeq (,$(findstring gcc,$(GCCV)))
#	DEFINED += -DHASH_MAP  
endif 
endif

ifeq ($(OSTYPE), SunOS)
	YACC = yacc -d -v 	
	DEFINED = -DHASH_MAP
	LINKFLAGS = -lxnet -lpthread -L $(LIBDIR0) -lfl
endif

CC = /usr/bin/g++
DEBUG = yes

# standard stuff:
CCFLAGS = -O2 -c $(DEFINED)

FEXOBJS = Fex.o FexParams.o Lexicon.o Parser.o Sparser.o	Flex.o RGF.o Sensor.o 
#Stats.o\

fex : $(FEXOBJS)
	$(CC) -O2 -o fex $(FEXOBJS) $(LINKFLAGS)

FEXDEPS = GlobalParams.h Lexicon.h Parser.h Sparser.h Fex.h 
#SendReceive.h
#Stats.h 

Fex.o : Fex.cpp $(FEXDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

FEXPARAMSDEPS = FexParams.h GlobalParams.h

FexParams.o : FexParams.cpp $(FEXPARAMSDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

LEXICONDEPS = Lexicon.h GlobalParams.h

Lexicon.o : Lexicon.cpp $(LEXICONDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

PARSERDEPS = Parser.h Fex.h

Parser.o : Parser.cpp $(PARSERDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

RGFDEPS = RGF.h Fex.h

RGF.o : RGF.cpp $(RGFDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

SensorDEPS = Sensor.h Fex.h

Sensor.o : Sensor.cpp $(SensorDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

#STATDEPS = Stats.h Fex.h
#Stats.o : Stats.cpp $(STATDEPS)
#	$(CC) $(CCFLAGS) -o $@ $*.cpp
#STATCALCDEPS = Stats.h GlobalParams.h
#Statcalc.o : Statcalc.cpp $(STATCALCDEPS)
#	$(CC) $(CCFLAGS) -o $@ $*.cpp

# script parser rules:

SPARSERDEPS = tokens.h 

Sparser.o: Sparser.cpp $(SPARSERDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.cpp

Sparser.cpp: tokens.h Sparser.h Sparser.y
	$(YACC) Sparser.y
	if cmp -s y.tab.h tokens.h; then rm y.tab.h; \
	else mv y.tab.h tokens.h; fi
	mv y.tab.c Sparser.cpp

FLEXDEPS = tokens.h Flex.h Sparser.h

Flex.o: Flex.c $(FLEXDEPS)
	$(CC) $(CCFLAGS) -o $@ $*.c

Flex.c: Flex.l
	$(LEX) -t Flex.l > Flex.c
#	mv lex.yy.c Flex.c

# clean up:

clean:
	rm -f core tokens.h Sparser.cpp Flex.c y.output $(FEXOBJS) fex
	echo "/* this file will be automatically generated. */" > tokens.h
