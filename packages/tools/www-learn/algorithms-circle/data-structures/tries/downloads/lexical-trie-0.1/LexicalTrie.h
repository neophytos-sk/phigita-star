
#ifndef LEXICAL_TRIE_H_
#define LEXICAL_TRIE_H_

#include <string>
#include <iostream>
#include <set>
#include <vector>

/*
 * Class: LexicalTrie
 *
 * This class implements a lexical trie.  A trie is a tree-like data structure
 * to store words, where each branch of the tree is tagged with a letter and
 * indicates the addition of that vector. At tree nodes, a boolean flag
 * indicates if the word up to that point is in fact contained in the trie.
 *
 * The trie supports lookup of words and prefixes, in addition to basic regular
 * expression support. You can populate the trie by adding words one at a time
 * or by reading words (one per line) from a std::istream.  You can also remove
 * individual words from the trie, and write the contents of the trie to a
 * std::ostream.
 *
 * Note that by default, the trie is case sensitive. You can change this behavior
 * by passing a flag to the constructor.
 */


class LexicalTrie
{
	public:

		/*
		 * Method: Constructor
		 *
		 * Initializes a new trie to represent an empty word list.
		 *
		 * Parameters:
		 *  caseSensitive - True if the trie is case sensitive.
		 *                 (true by default)
		 */
		LexicalTrie(bool caseSensitive = true);

		/*
		 * Method: Destructor
		 *
		 * The destructor frees any storage associated with the trie.
		 */
		~LexicalTrie();

		/*
		 * Method: addWord
		 *
		 * Adds the specified word to the trie.
		 *
		 * Parameters:
		 *  word - Word to add.
		 */
		void addWord(const std::string & word);

		/*
		 * Method: addWordsFromStream
		 *
		 * Adds words from an input stream, one per line.
		 *
		 * Parameters
		 *  input - Input stream to read lines from.
		 */
		void addWordsFromStream(std::istream & input);

		/*
		 * Method: removeWord
		 *
		 * Removes the specified word from the trie, freeing any memory which was
		 * allocated to store this word.  If the word does not exist in the trie,
		 * the trie is unchanged.
		 *
		 * Parameters:
		 *  word - String to remove.
		 */
		void removeWord(const std::string & word);

		/*
		 * Method: containsWord
		 *
		 * Returns true if the specified word exists in the trie, false otherwise.
		 *
		 * Parameters:
		 *  word - String to check.
		 *
		 * Returns:
		 *  True if the word is present.
		 */
		bool containsWord(const std::string & word);

		/*
		 * Method: containsPrefix
		 *
		 * Returns true if any words in the trie begin with the specified prefix,
		 * false otherwise.  A word is defined to be a prefix of itself and the
		 * empty string is a prefix of everything.
		 *
		 * Parameters:
		 *  prefix - Prefix to check.
		 *
		 * Returns:
		 *  True if any words in the trie start with the prefix.
		 */
		bool containsPrefix(const std::string & prefix);

		/*
		 * Method: writeToStream
		 *
		 * Writes the contents of the trie to an output stream. Words are written
		 * one per line.
		 * 
		 * Parameters:
		 *  output - The stream to write to.
		 */
		void writeToStream(std::ostream & out);

		/** Returns the number of words in the trie.
		 * 
		 * \return The number of words.
		 */
		int numWords();

		/*
		 * Method: matchRegExp
		 *
		 * Matches a regular expression against the contents of the trie. Stores
		 * the matches in the set 'results'. 
		 *
		 * Regular expression syntax:
		 *
		 * An asterisk indicates '0 or more characters'.  A question mark indicates
		 * '0 or 1 characters'.  Any other character means the literal character.
		 *
		 * Note that * and ? do not behave like in Perl; rather they are like the
		 * Unix shell expressions.
		 *
		 * Parameters:
		 *  exp - The regular expression.
		 *  results - The set to store results in.
		 */
		void matchRegExp(const std::string & exp, std::set<std::string> & results);

		struct Correction;
		
		/*
		 * Method: suggestCorrections
		 *
		 * Suggests corrections for a word. A correction is defined as a word
		 * within a maximum edit distance of the original word. Edit distance
		 * is the number of changes needed to go from the original to the
		 * correction. Adding, changing or removing a single letter is counted
		 * as one change. The results are added to the set passed as an
		 * argument.
		 *
		 * Parameters:
		 *  word - The word to find corrections for.
		 *  maxEditDistance - The maximum number of changes to allow.
		 *  results - The set to store results in.
		 *
		 */
		void suggestCorrections(const std::string & word, int maxEditDistance,
								std::set<Correction> & results);

		// DOCUMENTATION NOTE:
		// NaturalDocs will assume that everything after the following 'Class'
		// tag is part of the 'Correction' class. Oops. So, all documentation
		// for the 'LexicalTrie' class needs to be above this.

		/*
		 * Class: Correction
		 *
		 * Structure to represent a 'correction'. (Returned by the method
		 * 'suggestCorrections' below.) You might want to sort the corrections by
		 * proximity, hence the separate structure for corrections as opposed to
		 * simply returning a list of strings.
		 *
		 * Note that the ordering imposed by the overloaded < operator does *not*
		 * guarantee that two corrections with the same suggestion but different
		 * edit distances are equal. If you want to guarantee only one of each
		 * suggestion (e.g. the minimal distance) you will need to do that some
		 * other way.
		 */
		struct Correction
		{
			int editDistance_;
			std::string suggestedWord_;

			// constructor
			Correction(const std::string & word, int editD)
				: editDistance_(editD), suggestedWord_(word)
			{ /* empty */; }

			// default constructor
			Correction()
			{ /* empty */; }

			bool operator== (const Correction & other) const
			{
				return editDistance_ == other.editDistance_ &&
					suggestedWord_ == other.suggestedWord_;
			}

			bool operator< (const Correction & other) const
			{
				if (suggestedWord_ < other.suggestedWord_)
					return true;
				if (editDistance_ < other.editDistance_)
					return true;

				return false;
			}
		};

	private:

		// Helper function to handle keeping track of the correction set
		// Ensures that we only keep the lowest edit distance for a correction
		static void AddToCorrections(std::set<Correction> & theSet, const std::string & word,
									 int editDistance);

		struct TrieNode; // forward declaration

		TrieNode * root_; // root of the trie - created in Trie constructor
		int numWords_; // number of words in the trie
		bool caseSensitive_; // true if the trie is case sensitive

		// LetterTriePair: small data structure to store pairs of letters and trie
		// pointers.
		struct LetterTriePair
		{
			char letter_; // the letter
			TrieNode * trie_; // the trie node corresponding to this letter

			// default constructor
			LetterTriePair()
			{
				letter_ = '\0';
				trie_ = NULL;
			}

			// argument-constructor
			LetterTriePair(char letter, TrieNode * trie)
				: letter_(letter), trie_(trie)
			{ ; }

			// comparison operators (for the vector template)
			bool operator == (const LetterTriePair & another) const
			{
				return ( (letter_ == another.letter_) && (trie_ == another.trie_) );
			}
			bool operator != (const LetterTriePair & another) const
			{
				return ( (letter_ != another.letter_) || (trie_ != another.trie_) );
			}

			// sort operator
			bool operator< (const LetterTriePair & another) const
			{
				return letter_ < another.letter_;
			}
		};

		// PairCompare: small comparison function to sort the letters in the vector
		struct PairCompare
			: std::binary_function<LetterTriePair, LetterTriePair, bool>
		{
			bool operator() (const LetterTriePair & left,
							 const LetterTriePair & right)
			{
				return !std::greater<char>() (left.letter_, right.letter_);
			}
		};

		// TrieNode: support structure that stores a trie node, i.e. whether the
		// chain of letters up to that point constitutes a word, and all the other
		// letters that can be used to form words from this point onwards.
		struct TrieNode
		{
			bool isWord_; // do the letters up to here form a word?
			std::vector<LetterTriePair> letters_; // children

			TrieNode(); // constructor
			~TrieNode(); // destructor

			// Add this word (recursive)
			// Return true if actually added
			bool addWord(const std::string & word);

			// Is this prefix in the trie? (recursive)
			bool containsPrefix(const std::string & prefix);

			// Is this word in the trie? (recursive)
			bool containsWord(const std::string & word);

			// Remove this word (recursive)
			// Return true if we should delete memory
			// The 'removed' boolean is used to indicate if the word was removed,
			// so that the caller (the trie itself) knows to decrement the word count
			bool removeWord(const std::string & word, bool & removed);

			// Write contents to a stream (recursive)
			void writeToStream(std::ostream & out, const std::string & soFar = "");

			// Find all regex matches (recursive)
			void matchRegExp(std::set<std::string> & results,
							 const std::string & pattern,
							 const std::string & soFar = "");

			// Suggest spelling corrections (recursive)
			void suggestCorrections(std::set<Correction> & results,
									const std::string & word,
									int maxEditDistance, int editsUsed = 0,
									const std::string & soFar = "");

			// Find the letter/trie pair corresponding to this letter, or NULL if
			// not in the array
			LetterTriePair * findLetterPair(char letter);
		};
};

#endif
