all: test-union test-intersection

test-union:
	g++ -o test-union test-union.cc

test-intersection:
	g++ -o test-intersection test-intersection.cc

test:	all
	./test-union "12 34 56" "78 89"
	./test-union "1 2 3 5 8" "2 3 5 7 11"
	./test-intersection "2 4 62 21 78" "3 21 4 99 888"
	./test-intersection "1 2 3 5 8" "2 3 5 7 11"

clean:
	rm -f test-union *~
