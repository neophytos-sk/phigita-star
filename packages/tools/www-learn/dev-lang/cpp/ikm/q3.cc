class SomeClass
{
    protected:
        int data;
        friend class AnotherClass;
};

void SomeFunc(SomeClass sc)
{
    sc.data = 5;
}

class AnotherClass
{
    public:
        void Another(SomeClass sc)
        {
            sc.data = 25;
        }
        friend void SomeFunc(SomeClass sc);
};

int main(void)
{
    SomeClass sc;
    SomeFunc(sc);
    cout << sc.data;
}
