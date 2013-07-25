/* Max-Spacing k-Clusterings
 * the spacing of a k-clustering is min_of_separates_{p,q} d(p,q)
 */


#include <iostream>
#include <fstream>
#include <queue>
#include <string>
#include <map>
#include <vector>

using namespace std;

int ones(const string& s1) {
  int count=0;
  for(int i=0;i<s1.size();i++)
    if (s1[i]=='1')
      count++;

  return count;
}

struct bits_comparator {
    bool operator()(const string& s1, const string& s2) {
      int ones1 = ones(s1);
      int ones2 = ones(s2);
      if (ones1==ones2)
	return s1>s2;
      else
	return ones(s1) > ones(s2); 
    }
};

int hamming_distance(int num_bits, const string& s1, const string& s2) {
  int dist=0;
  for(int i=0; i<num_bits; i++) 
    if (s1[i] != s2[i])
      dist++;

  return dist;
}

string add(int num_bits, const string& s1, const string& s2) {
  string result(num_bits,' ');
  int carry=0;
  for(int i=num_bits-1; i>=0; i--) {
    if (s1[i]=='1' && s2[i]=='1') {
      if (carry)
	result[i]='1';
      else
	result[i]='0';
      carry=1;
    } else if (s1[i]=='0' && s2[i]=='0') {
      if (carry)
	result[i]='1';
      else
	result[i]='0';
      carry=0;
    } else if ((s1[i]=='1' && s2[i]=='0') || (s1[i]=='0' && s2[i]=='1')) {
      if (carry) {
	result[i]='0';
      } else {
	result[i]='1';
      }
      carry=0;
    }
  }
  return result;
}

int main(int argc, char **argv) {

  if (argc!=2) {
    cout << "Usage: " << argv[0] << " filename" << endl;
    return 1;
  }

  ifstream infile;
  infile.open(argv[1]);

  int num_nodes,num_bits;
  infile >> num_nodes;
  infile >> num_bits;
  priority_queue<string,vector<string>, bits_comparator> pq;
  map<int,vector<string> > m;
  //priority_queue<string> pq;
  for(int i=0;i<num_nodes;++i) {
    string bits(num_bits,' ');
    for(int j=0; j<num_bits;++j)
      infile >> bits[j];

    pq.push(bits);
    m[ones(bits)].push_back(bits);
  }
  infile.close();

  int cluster[num_nodes+1];
  int k=0;
  string prev_bits(num_bits,' ');
  while(!pq.empty()) {
    string bits1 = pq.top();
    pq.pop();
    if (pq.empty()) break;
    string bits2 = pq.top();
    pq.pop();
    // cout << bits1 << " " << hamming_distance(num_bits,bits1,bits2) << endl;
    if (hamming_distance(num_bits,bits1,bits2) >= 3) {
      ++k;

      pq.push(add(num_bits,bits1,bits2));
      // cout << "k=" << k << " " << add(num_bits,bits1,bits2) << endl;
    }

  }

  cout << "k = " << k << endl;
  return 0;

}
