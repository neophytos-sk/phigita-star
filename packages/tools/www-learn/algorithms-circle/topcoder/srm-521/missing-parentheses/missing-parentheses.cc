#include <string>
#include <iostream>

using namespace std;

int count_corrections(const string& str) {
	int a=0,b=0;
	for(int i=0;i<str.size();++i) {
		if (str[i]=='(') {
			a++;
		} else {
			a--;
		}
		if (a<0) {
			b++;
			a=0;
		}
	}
	return a+b;
}


int main(int argc, char *argv[]) {
	if (argc<2) {
		cout << "usage: " << argv[0] << "parentheses" << endl;
		return 1;
	}
	string par(argv[1]);
	cout << count_corrections(par) << endl;
	return 0;
}