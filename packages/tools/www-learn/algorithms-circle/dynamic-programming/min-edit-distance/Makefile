all: editdist_m1 editdist_m2

editdist_m1:
	gcc -o editdist_m1 editdist_m1.c

editdist_m2:
	gcc -o editdist_m2 editdist_m2.c

test:	all
	./editdist_m1 abc ababa
	./editdist_m2 abc ababa
	./editdist_m1 "this is a test" "this is another test"
	./editdist_m2 "this is a test" "this is another test"

clean:
	rm -f editdist_m1 editdist_m2 *~
