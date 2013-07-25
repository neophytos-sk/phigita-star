/* find all substrings that are palindromes within an input string
 * e.g. for string "abbcacbca" output should be: [cac, bcacb, cbc, acbca, bb]
 */
 
#include <iostream>
#include <string>

using namespace std;

bool check_palindrome(const string& s, int start, int end) {
	if (end-start==0) return false;
	int i = start, j=end;
	while (i<j) {
		if (s[i]!=s[j])
			return false;
		i++;
		j--;
	}
	return true;
}

void find_palindromes(const string& s) {
	int len = s.size();
	for (int i = 0; i < len; i++) {
		for (int j=i;j<len;j++) {
			if (check_palindrome(s,i,j)) {
				cout << s.substr(i,j-i+1) << endl;
			}
		}
	}
}


int main() {
	string s = "abbcacbca";
	find_palindromes(s);
	return 0;
}