
CC = g++
CFLAGS = -Wall --pedantic


all: main.o LexicalTrie.o
	$(CC) $^ -o trie
	

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

