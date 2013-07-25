CC=gcc
CFLAGS=-Wall -pedantic -std=iso9899:1999

all: simplethreads test_threads

thread:
	$(CC) $(CFLAGS) -fPIC -shared -c -o libthread.so thread.c  -I../linked-list

test_threads: thread
	$(CC) $(CFLAGS) -o test_threads test_threads.c -lthread -lpthread -lllist -L. -L../linked-list/

simplethreads:
	$(CC) $(CFLAGS) -o simplethreads simplethreads.c -lpthread

clean:
	rm -f simplethreads test_threads *~
