all: tokenize

tokenize:
	gcc -o tokenize tokenize.c

test: all
	./tokenize "Hello,How,Are,You,Today"

clean:
	rm -f a.out tokenize *~
