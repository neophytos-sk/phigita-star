CC     = g++
CFLAGS = -g -I/opt/clucene/include/ -L/opt/clucene/lib/ -lclucene-core -lclucene-shared
DEPS   = tlucene.h
OBJ    = main.o tlucene.o
EXT    = cc

all:	tlucene

%.o:	%.${EXT} ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

tlucene:	${OBJ}
		${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f tlucene *.o *~
