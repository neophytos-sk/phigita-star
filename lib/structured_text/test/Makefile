
CC     = g++
CFLAGS = -O3 -I../cc -I/opt/naviserver/include -ltcl 
DEPS   = structured_text.h
OBJ    = stx-main.o structured_text.o
EXT    = cc

all:	stx

stack.o:
	gcc -O3 -c -o stack.o stack.c ${CFLAGS}

%.o:	%.${EXT} ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

stx:	${OBJ} stack.o
	${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f stx *.o *~ 
