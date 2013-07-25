
#include <iostream>

template <class T> class Some
{
public:
   static int stat;
};

template<class T>
int Some<T>::stat = 10;

int main(void)
{
   Some<int>::stat = 5;
   std::cout << Some<int>::stat   << std::endl;
   std::cout << Some<char>::stat  << std::endl;
   std::cout << Some<float>::stat << std::endl;
   std::cout << Some<long>::stat  << std::endl;
}
