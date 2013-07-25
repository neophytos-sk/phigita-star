#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

using namespace std;

int main() {
    vector<int> vec = {1,2,3,4};
    for_each(vec.begin(),vec.end(), [](int &v) { v*=v; });
    copy(vec.begin(),vec.end(),ostream_iterator<int>(cout,"\n"));
    return 0;
}
