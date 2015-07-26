all:
	gcc -o main -lm main.c bloom.c murmur_hash2.c

test:
	./main this is abc test
	./main this is defgh test
	./main this is a test

clean:
	rm -f main
