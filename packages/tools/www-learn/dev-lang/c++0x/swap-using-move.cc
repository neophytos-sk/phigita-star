#include <iostream>
#include <algorithm>
#include <vector>
#include <iterator>

using namespace std;

template <class T>
void swap(T a, T b)
{
    T tmp(move(a));
    a = move(b);
    b = move(tmp);
}

int main() {
    vector<int> v1 = {1,2,3,4};
    vector<int> v2;
    swap<int>(v1,v2);
    copy(v2.begin(),v2.end(),ostream_iterator<int>(cout,"\n"));
    return 0;
}
