#include <algorithm>
#include <string>
#include <iostream>

using namespace std;

int main(int argc, char *argv[]) {
	string str("hello world");
	sort(str.begin(),str.end());
	cout << str << endl;
	
	return 0;
}