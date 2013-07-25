CC     = g++
CFLAGS = -O3
DEPS   = structured_text.h
OBJ    = document_distance.o datapoint.o cluster.o datamap.o evaluator.o main.o


all:	test_main

%.o:	%.c ${DEPS}
	${CC} -c -o $@ $< ${CFLAGS}

test_main: ${OBJ}
	${CC} -o $@ $^ ${CFLAGS}

test:	all
	./test.sh

clean:
	rm -f a.out test_main *.o *~


