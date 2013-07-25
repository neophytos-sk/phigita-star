#include <iostream>

class Base
{
public:
};
class Derived : public Base
{
};

void somefunc(Base b) { std::cout << "base b"; }
void somefunc(Base& b) { std::cout << "base& b"; }
void somefunc(Derived d) { std::cout << "der d"; }
void somefunc(Derived& d) { std::cout << "der &b"; }

int main()
{
    Base* base = new Derived;
    delete base;
Derived d;
somefunc(d);
}
