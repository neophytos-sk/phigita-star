all:	example-inheritance example-protected example-virtual-destructor example-friend

example-inheritance:
	g++ -o example-inheritance example-inheritance.cc

example-protected:
	g++ -o example-protected example-protected.cc

example-virtual-destructor:
	g++ -o example-virtual-destructor example-virtual-destructor.cc

example-friend:
	g++ -o example-friend example-friend.cc

test:
	echo "==================="
	./example-inheritance
	echo "==================="
	./example-protected
	echo "==================="
	./example-virtual-destructor
	echo "==================="
	./example-friend

clean:
	rm -f example-inheritance example-protected example-virtual-destructor example-friend *~

