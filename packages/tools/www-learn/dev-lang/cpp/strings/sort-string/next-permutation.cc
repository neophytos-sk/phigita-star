#include <string>
#include <iostream>
#include <algorithm>

using namespace std;

int main(int argc, char *argv[]) {
	string str = "abc";
	while(next_permutation(str.begin(),str.end())) {
		cout << str << endl;
	}
	return 0;
}
