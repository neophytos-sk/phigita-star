#-I/web/service-phigita/lib/structured_text/cc/

CC     = g++
CFLAGS = -O3 -I/opt/naviserver/include/tcl -ltcl
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
	rm -f stx *.o *~ 
