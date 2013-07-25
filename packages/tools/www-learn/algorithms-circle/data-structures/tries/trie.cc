#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
//#include <map>
#include <tr1/unordered_map>

using std::tr1::unordered_map;
//using std::map;
using std::vector;
using std::string;




#define DISALLOW_COPY_AND_ASSIGN(T) \
  T(const T& other); \
  void operator=(const T& other);

class Trie {
public:
  Trie();
  void add_word(string word);
  bool is_word();
  void suggest_corrections(string word, int max_edit_distance, vector<string>& corrections, const string& sofar = "");
  int countWords(string word, int missing_letters);
  int countPrefixes(string prefix);
private:
  int words_;
  int prefixes_;
  unordered_map<char,Trie*> edges;

};

Trie::Trie() : words_(0), prefixes_(0) {}

void Trie::add_word(string word) {

  if (word.empty()) {
    ++words_;
  } else {
    ++prefixes_;
    //int k = word[0]-'a'; // first character
    char ch = word[0];

    if(!edges.count(ch))
      edges[ch] = new Trie();

    //word.erase(word.begin()); // cut left most character
    edges[ch]->add_word(word.substr(1));

  }
}

bool Trie::is_word() {
  return words_ > 0;
}

void Trie::suggest_corrections(string word, 
			       int max_edit_distance, 
			       vector<string>& results,
			       const string& sofar) {

  printf("%s - %s\n",sofar.c_str(),word.c_str());

  if (word.empty() && is_word()) {
    results.push_back(sofar);
  }

  if (word.empty() && max_edit_distance==0)
    return;

  char ch = word[0];
  if (max_edit_distance == 0) {
    if (edges.count(ch)) {
      edges[ch]->suggest_corrections(word.substr(1),max_edit_distance,results,sofar+ch);
    }
  } else {

    // try skipping one letter
    if (!word.empty())
      this->suggest_corrections(word.substr(1),max_edit_distance-1,results,sofar);
    
    // try every child
    for (unordered_map<char,Trie*>::const_iterator it = edges.begin();
	 it != edges.end();
	 ++it) {
      
      if(!word.empty()) {
	// if the letter matches, try doing nothing and moving on
	if (it->first == ch)
	  it->second->suggest_corrections(word.substr(1),max_edit_distance,results,sofar+ch);
	// TODO - HERE: MAYBE, NEEDS AN ELSE
	// try changing a letter - skip one letter, but try adding every child letter instead
	it->second->suggest_corrections(word.substr(1), max_edit_distance-1,results,sofar+it->first);
      }
      
      // try adding a letter - do not skip a letter, and try adding every child letter
      it->second->suggest_corrections(word,max_edit_distance-1,results,sofar+it->first);
      
    }
  }

}


int main(int argc, char *argv[]) {

  if (argc < 3) {
    fprintf(stderr,"Usage: %s max_edit_distance word1 ...\n",argv[0]);
    return 1;
  }

  int max_edit_distance = atoi(argv[1]);

  Trie trie;
  for (int i = 2; i<argc; ++i)
    trie.add_word(argv[i]);

  vector<string> corrections;
  trie.suggest_corrections("hello",max_edit_distance,corrections);

  printf("---------------------------\n");
  printf("number of corrections: %zd\n", corrections.size());

  for (vector<string>::iterator it = corrections.begin();
       it != corrections.end();
       ++it) 
    printf("%s\n",it->c_str());

  //printf("countWords('hello',0)=%d\n",trie.countWords("hello",0));
  //printf("countWords('hello',1)=%d\n",trie.countWords("hello",1));
  //printf("countWords('hello',2)=%d\n",trie.countWords("hello",2));

  return 0;
}
