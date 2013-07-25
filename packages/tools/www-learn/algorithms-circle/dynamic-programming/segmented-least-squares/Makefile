all: segmented-least-squares

segmented-least-squares:
	g++ -o sls segmented-least-squares.cc

test:	all
	./sls 0.2 unsorted_data.txt

clean:
	rm -f a.out *~ sls
