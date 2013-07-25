all: remove_string

remove_string:
	gcc -o remove_string remove_string.c

test: remove_string
	./remove_string theabcthabdtheshhtexyztheaaatheb the

clean:
	rm -f remove_string a.out *~
