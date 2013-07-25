/*

  The nth term of the sequence of triangle numbers is given by, tn = ½n(n+1); 
  so the first ten triangle numbers are:

  1, 3, 6, 10, 15, 21, 28, 36, 45, 55, ...

  By converting each letter in a word to a number corresponding to its 
  alphabetical position and adding these values we form a word value. For 
  example, the word value for SKY is 19 + 11 + 25 = 55 = t10. If the word value
  is a triangle number then we shall call the word a triangle word.

  Using words.txt (right click and 'Save Link/Target As...'), a 16K text file 
  containing nearly two-thousand common English words, how many are triangle 
  words?

*/

#include <iostream>
#include <fstream>
#include <map>
#include <string>

using std::cout;
using std::map;
using std::ifstream;
using std::string;
using std::getline;
using std::remove; 


int word_value(const string& word) {
  string::const_iterator it = word.begin();
  const string::const_iterator end = word.end();
  int sum = 0;
  for(;it!=end;++it) {
    char ch = *it;
    sum += (ch - 'A') + 1;
  }
  return sum;
}


int main() {

  map<int,int> triangle_nums;
  for(int i=1;i<100;i++) {
    int sum = i*(i+1)/2;
    triangle_nums[sum] = 1;
  }

  ifstream infile;
  infile.open("words.txt");
  string word;
  int count_triangle_words = 0, total=0;
  while(getline(infile,word,',')) {
    word.erase(word.begin());
    word.erase(word.end()-1);
    if (triangle_nums.count(word_value(word)) != 0) {
      cout << "triangle word: " << word << '\n';
      ++count_triangle_words;
    } 
    ++total;
  }
  cout << "total number of words = " << total << '\n';
  cout << "number of triangle words = " << count_triangle_words << '\n';

  return 0;

}
