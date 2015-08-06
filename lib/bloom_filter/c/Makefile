all:
	gcc -o main -lm -I../../core/c -I../../murmur_hash/c main.c bloom.c ../../murmur_hash/c/murmur_hash2.c

test:
	./main this is abc test
	./main this is defgh test
	./main this is a test

clean:
	rm -f main
