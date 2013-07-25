#include <iostream>

using namespace std;

int main() {
    auto f1 = [](int x) { return x * 2; };
    cout << f1(14) << endl;
    int scope_value = 42;
    auto f2 = [=](int x) { return scope_value*x; };
    cout << f2(14) << endl;
    return 0;
}
