#-I/web/service-phigita/lib/structured_text/cc/

CC     = gcc
CFLAGS = -g -O3
DEPS   = ../c/critbit.h
OBJ    = critbit_test.o critbit.o
EXT    = c

all:	critbit_test

%.o:	%.${EXT} ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

critbit_test:	${OBJ}
	${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f critbit_test *.o *~
