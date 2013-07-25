

#include <iostream>
#include <string>
#include <fstream>
#include "LexicalTrie.h"

using namespace std;

int main(int argc, char ** argv)
{
	if (argc < 2)
	{
		cout << "usage: trie <input file>" << endl;
		return 1;
	}

	LexicalTrie trie;

	ifstream in(argv[1]);

	trie.addWordsFromStream(in);

	cout << "Done; words in trie: " << trie.numWords() << endl;

	set<LexicalTrie::Correction> suggs;
	trie.suggestCorrections("bote", 1, suggs);

	cout << "Suggested corrections for 'bote', e.d. = 1: " << endl;
	cout << "  ";
	for (set<LexicalTrie::Correction>::iterator it = suggs.begin(); it != suggs.end(); it++)
	{
		cout << it->suggestedWord_ << " ";
	}
	cout << endl;

	string foo;
	getline(cin, foo);

	return 0;
}

