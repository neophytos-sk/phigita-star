#include <iostream>
#include <tuple>

using std::cout;
using std::endl;

int main() {
    std::tuple<double, int> tup(45.6,89);
    double value_0 = std::get<0>(tup);
    std::get<1>(tup) = 666;
    value_0=12.3;
    cout << std::get<0>(tup) << endl;
    cout << std::get<1>(tup) << endl;
    return 0;
}
