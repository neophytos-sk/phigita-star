#include<string>
#include<iostream>

using namespace std;

int main()
{

  string myString;
  cin >> myString;
  for(int i=0;i<myString.size();++i)
    cout << myString[i] << endl;

  return 0;

}
