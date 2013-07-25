all:	test-llist libllist.so

libllist.so:
	gcc -fPIC -shared -c -o libllist.so llist.c

test-llist:
	gcc -o test-llist test-llist.c llist.c

clean:
	rm -f test-llist *~

