#-I/web/service-phgt-0/lib/structured_text/cc/

CC     = gcc
CFLAGS = -g -O3 -lm
DEPS   = token.h eval.h
OBJ    = main.o token.o eval.o
EXT    = c

all:	main_calc

%.o:	%.${EXT} ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

main_calc:	${OBJ}
	${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f critbit_test *.o *~
