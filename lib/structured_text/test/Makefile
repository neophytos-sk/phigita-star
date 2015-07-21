CC     = gcc
CFLAGS = -Wall -O3 -DNDEBUG -I../c -I/opt/tcl/include -L/opt/tcl/lib -I../../struct/include -ltcl 
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
	rm -f stx *.o *~ ../c/*.o
