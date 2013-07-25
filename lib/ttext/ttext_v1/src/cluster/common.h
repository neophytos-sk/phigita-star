#include <string>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <tcl.h>

using namespace std;

bool getLines(string filename,vector<string>* lines);
bool getText(string filename,string* text);
string toLower(string str);
string replaceAll(string str);
string trim(string line);
string clearString(string str);
string getFilePath(string filename);
vector<string> getTokens(string str);
int compareStrings(string s1, string s2);
