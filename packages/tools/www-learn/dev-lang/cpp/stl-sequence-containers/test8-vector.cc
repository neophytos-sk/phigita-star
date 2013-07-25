#include <vector>
#include <iterator>
#include <iostream>


using namespace std;

int main() {
  vector<int> myValues;


  myValues.push_back(10);
  myValues.push_back(888);
  myValues.push_back(20);
  myValues.push_back(30);
  myValues.push_back(40);

  copy(myValues.begin(),myValues.end(),ostream_iterator<int>(cout,"\n"));

  myValues.erase(myValues.begin());


  cout << "---------- after erase of the first element of the vector" << '\n';

  copy(myValues.begin(),myValues.end(),ostream_iterator<int>(cout,"\n"));

  return 0;
}
