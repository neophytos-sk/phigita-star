
class SomeClass
{
    public:
        int data;
    protected:
        class Nest
        {
            public:
            int nested;
        };
    public:
        static Nest* createNest(){return new Nest;}
};

class Derived : public SomeClass {
};

void use_someclass()
{
    //SomeClass::Nest* nst = SomeClass::createNest();
    //nst->nested = 5;
    Derived d;
    d.createNest();
}

int main(){use_someclass();}
