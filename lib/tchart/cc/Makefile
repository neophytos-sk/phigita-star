all:
	g++ -o test chart.cc -lgd -lm

clean:
	rm -f *.o test a.out test.png

test:	all
	./test
	display example.png
