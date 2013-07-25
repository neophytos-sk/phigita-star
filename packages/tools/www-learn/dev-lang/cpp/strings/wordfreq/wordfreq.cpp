// List all words in input file, with counts and freqs
#include <string>
#include <map>
#include <iostream>
#include <iomanip>

using namespace std;

int main()
{
  map<string,int> wc;
  string word;

  int total=0;
  while(cin >> word) {
    ++wc[word];
    ++total;
  }

  double freq;
  const map<string,int>::iterator stop = wc.end();
  for(map<string,int>::iterator it = wc.begin(); it!=stop; ++it) 
  {
    freq = (double) it->second / (double) total;
    cout << setw(10) << left << it->first << " " 
	 << setw(10) << it->second
	 << setw(10) << freq << endl;
  }

}
