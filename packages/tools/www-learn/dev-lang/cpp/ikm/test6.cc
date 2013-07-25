#include <iostream>
using namespace std;

class Base
{
    public:
    Base(){cout << "In Base Ctor\n";}

    class Nest
    {
        public:
        Nest(){cout << "In Nest Ctor\n"; }
    };   
};

class Derive : public Base
{
    public:       
    Derive(){cout << "In Derive Ctor\n"; }
}; 

int main(){ Derive d;  }
