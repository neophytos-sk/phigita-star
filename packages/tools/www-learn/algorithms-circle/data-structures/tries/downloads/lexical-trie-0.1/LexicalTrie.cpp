
#include <iostream>
#include <algorithm>
#include "LexicalTrie.h"
#include <assert.h>

using namespace std;

// Helper function: StringToLower
static std::string StringToLower(const std::string & str)
{
	std::string result;

	result.reserve(str.length());

	for (std::string::size_type i = 0; i < str.length(); i++)
	{
		result[i] = tolower(str[i]);
	}

	return result;
}

LexicalTrie::LexicalTrie(bool caseSensitive)
{
	root_ = new TrieNode();
	numWords_ = 0;
	caseSensitive_ = caseSensitive;
}
LexicalTrie::~LexicalTrie()
{
	delete root_;
}

void LexicalTrie::addWord(const std::string & word)
{
	bool added;

	if (caseSensitive_)
		added = root_->addWord(word);
	else
		added = root_->addWord(StringToLower(word));
	
	if (added)
		numWords_++;
}

void LexicalTrie::addWordsFromStream(std::istream & in)
{
	while ( true )
	{
		string word;
		getline(in, word);
		if ( !in.fail() )
		{
			if ( word == "" )
			  assert(false && "stream had empty line!");
			else
				this->addWord(word);
		}
		else
			break;
	};
}

bool LexicalTrie::containsPrefix(const std::string & prefix)
{
	if (caseSensitive_)
		return root_->containsPrefix(prefix);
	else
		return root_->containsPrefix(StringToLower(prefix));
}

bool LexicalTrie::containsWord(const std::string & word)
{
	if (caseSensitive_)
		return root_->containsWord(word);
	else
		return root_->containsWord(StringToLower(word));
}

void LexicalTrie::matchRegExp(const std::string & exp, std::set<std::string> & results)
{
	if (caseSensitive_)
		root_->matchRegExp(results, exp);
	else
		root_->matchRegExp(results, StringToLower(exp));
}

int LexicalTrie::numWords()
{
	return numWords_;
}

void LexicalTrie::removeWord(const std::string & word)
{
	bool removed;

	if (caseSensitive_)
		removed = root_->removeWord(word, removed);
	else
		removed = root_->removeWord(StringToLower(word), removed);

	if (removed)
		numWords_--;
}

void LexicalTrie::suggestCorrections(const std::string & word, int maxEditDistance,
								std::set<LexicalTrie::Correction> & results)
{
	if (caseSensitive_)
		root_->suggestCorrections(results, word, maxEditDistance);
	else
		root_->suggestCorrections(results, StringToLower(word), maxEditDistance);
}

void LexicalTrie::writeToStream(ostream & out)
{
	root_->writeToStream(out);
}

/*
 * Helper function to handle keeping track of the correction set
 * Ensures that we only keep the lowest edit distance for a correction
 */
void LexicalTrie::AddToCorrections(std::set<Correction> & theSet,
                           const std::string & word, int editDistance)
{
	std::set<Correction>::iterator it = theSet.find(Correction(word, editDistance));

	if (it == theSet.end())
	{
		// Not found... so add it
		theSet.insert(Correction(word, editDistance));
	}
	else
	{
		// Found... update it to the minimum edit distance
		int prevDist = it->editDistance_;
		theSet.erase(it);
		theSet.insert( Correction(word, std::min(prevDist, editDistance)) );
	}
}


/*
==================================
   ____                        __ 
  / __/_ _____  ___  ___  ____/ /_
 _\ \/ // / _ \/ _ \/ _ \/ __/ __/
/___/\_,_/ .__/ .__/\___/_/  \__/ 
        /_/  /_/                  
  _______                   
 / ___/ /__ ____ ___ ___ ___
/ /__/ / _ `(_-<(_-</ -_|_-<
\___/_/\_,_/___/___/\__/___/
                            
==================================
*/

/*********************************
 * TrieNode                     *
 *********************************/

// Constructor
LexicalTrie::TrieNode::TrieNode()
{
	isWord_ = false;
}
// Destructor
LexicalTrie::TrieNode::~TrieNode()
{
	// Clear children
	for (std::vector<LetterTriePair>::iterator it = letters_.begin();
		 it != letters_.end();
		 it++)
	{
		delete it->trie_;
	}
}

bool LexicalTrie::TrieNode::addWord(const std::string & word)
{
	// recursive base case:
	if ( word == "" )
	{
		bool added = false;

		// was this not already a word?
		if (!isWord_)
			added = true;

		isWord_ = true;
		return added;
	}

	LetterTriePair * pair = findLetterPair(word[0]);
	if (pair)
	{
		// pair exists so update it...
		return pair->trie_->addWord(word.substr(1));
	}
	else
	{
		// pair doesn't exist, so create it
		TrieNode * newTrie = new TrieNode();

		// add the word recursively to the new trie
		newTrie->addWord(word.substr(1));

		letters_.push_back(LetterTriePair(word[0], newTrie));

		// keep the vector sorted
		sort(letters_.begin(), letters_.end());

		// in this case, the word was added because we didn't have
		// this branch to begin with...
		return true;
	}
}

bool LexicalTrie::TrieNode::containsPrefix(const std::string & prefix)
{
	// recursive base case
	if ( prefix == "" )
		return true;

	LetterTriePair * pair = this->findLetterPair(prefix[0]);
	if ( !pair )
		return false; // letter doesn't exist - prefix not in trie
	else
		return pair->trie_->containsPrefix( prefix.substr(1) );
}

bool LexicalTrie::TrieNode::containsWord(const std::string & word)
{
	if ( word == "" )
	{
		if (isWord_)
			return true;
		else
			return false;
	}

	LetterTriePair * pair = this->findLetterPair(word[0]);
	if ( !pair )
		return false;
	else
		return pair->trie_->containsWord(word.substr(1));
}

/*void LexicalTrie::TrieNode::Print(int depth)
{
	//PrintSpaces(depth);
	cout << (this->isWord == 0 ? "Word:  No" : "Word: Yes");
	cout << " - " << this->Letters.GetSize() << " children, ";
	cout << this->Letters.GetCapacity() << " capacity.";
	cout << endl;
	for ( size_t pos = 0; pos < Letters.GetSize(); pos++ )
	{
		PrintSpaces(depth+1);
		cout << Letters[pos].Letter << ": ";
		Letters[pos].Trie->Print(depth + 1);
	}
}*/

bool LexicalTrie::TrieNode::removeWord(const std::string & word, bool & removed)
{
	if ( word == "" )
	{
		// if this already was a word, mark that we removed it
		if (isWord_)
			removed = true;

		this->isWord_ = false;

		// are we empty?
		if ( letters_.size() == 0 )
			return true; // true: delete the node
		else
			return false; // false: don't delete - still has children
	}

	LetterTriePair * pair = this->findLetterPair(word[0]);
	if ( !pair )
		return false;

	if ( pair->trie_->removeWord(word.substr(1), removed) )
	{
		delete pair->trie_;

		std::vector<LetterTriePair>::iterator it = find(letters_.begin(), letters_.end(), *pair);

		letters_.erase(it, it+1);

		// We removed the node... maybe we have no children left?
		if ( letters_.size() == 0 && isWord_ == false )
			return true;
	}

	return false;
}

void LexicalTrie::TrieNode::writeToStream(ostream & out, const std::string & soFar)
{
	if ( isWord_ )
		out << soFar << endl;

	for ( std::vector<LetterTriePair>::iterator it = letters_.begin();
		  it != letters_.end(); it++ )
	{
		it->trie_->writeToStream(out, soFar + it->letter_);
	}
}

void LexicalTrie::TrieNode::matchRegExp(std::set<std::string> & resultSet,
                                const std::string & pattern,
								const std::string &soFar)
{
	// do the pattern and string match? (i.e. no wildcards)
	if ( pattern == "" && soFar != "" )
	{
		if ( this->isWord_ )
			resultSet.insert(soFar);
		return;
	}

	std::vector<LetterTriePair>::iterator it;

	switch ( pattern[0] )
	{
		case '*':
			// Try matching 1 or more characters
			for (it = letters_.begin(); it != letters_.end(); it++)
			{
				it->trie_->matchRegExp(resultSet, pattern,
					soFar + it->letter_);
			}

			// Try matching 0 characters
			this->matchRegExp(resultSet, pattern.substr(1), soFar);
			break;

		case '?':
			// Try matching no character
			this->matchRegExp(resultSet, pattern.substr(1), soFar);
			
			// Try matching one character
			for (it = letters_.begin(); it != letters_.end(); it++)
			{
				it->trie_->matchRegExp(resultSet, pattern.substr(1),
					soFar + it->letter_);
			}
			break;

		default:
			// just make sure the letter matches - see if we have that letter from here
			LetterTriePair * pair = this->findLetterPair( pattern[0] );
			if (pair)
			{
				// we have it - remove it from pattern,
				// add to soFar, and continue
				pair->trie_->matchRegExp(resultSet,
					pattern.substr(1), soFar + pair->letter_);
			}
			else
			{
				// we don't have the letter... abort
				return;
			}
			break;
	}
}

void LexicalTrie::TrieNode::
		suggestCorrections(std::set<LexicalTrie::Correction> & results,
						   const std::string & word, int maxEditDistance,
						   int editsUsed, const std::string & soFar)
{
	if ( this->isWord_ && word == "" )
	{
		LexicalTrie::AddToCorrections(results, soFar, editsUsed);
	}

	if ( word == "" && editsUsed == maxEditDistance )
		return; // can't go on...

	if ( editsUsed == maxEditDistance )
	{
		// We've used up all our changes... so we can only go on if the
		// letters match. First, see if we have the letter at this node...
		LetterTriePair * pair = this->findLetterPair( word[0] );
		if ( pair )
		{
			// We have it...
			pair->trie_->suggestCorrections(results, word.substr(1),
				maxEditDistance, editsUsed, soFar + word[0]);
		}
	}
	else
	{
		// First try removing a letter (effectively skipping one)
		if ( word != "" )
		{
			this->suggestCorrections(results, word.substr(1),
				maxEditDistance, editsUsed + 1, soFar );
		}

		// Try every child...
		for ( std::vector<LetterTriePair>::iterator it = letters_.begin();
			  it != letters_.end(); it++ )
		{
			// Only do the following if the word is not empty
			if ( word != "" )
			{
				// If the letter matches, then try doing nothing and moving on
				if ( it->letter_ == word[0] )
				{
					it->trie_->suggestCorrections(results, word.substr(1),
						maxEditDistance, editsUsed, soFar + word[0] );
				}

				// Then try changing a letter - skip one letter, but try adding
				// every child letter instead
				it->trie_->suggestCorrections(results, word.substr(1),
					maxEditDistance, editsUsed + 1, soFar + it->letter_ );
			}

			// Then try adding a letter - do not skip a letter, and try adding
			// every child letter
			it->trie_->suggestCorrections(results, word,
				maxEditDistance, editsUsed + 1, soFar + it->letter_ );
		}
	}
}

/* TrieNode::FindLetterPair
 * -------------------------
 * Search a trie node for a given letter child node. Return the pair structure
 * (that contains both the letter and the pointer to the child trie.)
 */
LexicalTrie::LetterTriePair * LexicalTrie::TrieNode::findLetterPair(char letter)
{
	for (std::vector<LetterTriePair>::iterator it = letters_.begin();
		 it != letters_.end(); it++ )
	{
		if ( it->letter_ == letter )
			return &(*it);
	}
	return NULL;
}
