CC     = gcc
# -pedantic
CFLAGS = -Wall -Wall -O3 -DNDEBUG -I../c -I/opt/naviserver/include -ltcl 
DEPS   = structured_text.h
OBJ    = stx-main.o structured_text.o
EXT    = c

all:	stx

%.o:	%.${EXT} ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

stx:	${OBJ}
	${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f stx *.o *~ 
