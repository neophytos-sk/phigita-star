#-I/web/service-phgt-0/lib/structured_text/cc/

CC     = g++
CFLAGS = -g -O3
DEPS   = structured_text.h
OBJ    = stx-main.o structured_text.o
EXT    = cc

all:	stx

%.o:	%.${EXT} ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

stx:	${OBJ}
	${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f stx *.o *~ sha1-c/*.o
