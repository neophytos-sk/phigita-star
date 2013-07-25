#include <string>
#include <iostream>

template <typename FirstType, typename SecondType> class MyPair
{
public:
  FirstType getFirst();
  SecondType getSecond();
  void setFirst(FirstType newValue);
  void setSecond(SecondType newValue);
  void swap(MyPair& other);
private:
  FirstType first;
  SecondType second;
};


template <typename FirstType, typename SecondType>
FirstType MyPair<FirstType, SecondType>::getFirst()
{
  return first;
}

template <typename FirstType, typename SecondType>
SecondType MyPair<FirstType, SecondType>::getSecond()
{
  return second;
}


template <typename FirstType, typename SecondType>
void MyPair<FirstType, SecondType>::setFirst(FirstType newValue)
{
  first=newValue;
}

template <typename FirstType, typename SecondType>
void MyPair<FirstType, SecondType>::setSecond(SecondType newValue)
{
  second=newValue;
}

template <typename FirstType, typename SecondType>
void MyPair<FirstType, SecondType>::swap(MyPair& other)
{
  MyPair temp(other);
  other.setFirst(first);
  other.setSecond(second);
  first = temp.getFirst();
  second = temp.getSecond();
}



using namespace std;

int main()
{
  MyPair<int,string> thePair;
  thePair.setFirst(12);
  thePair.setSecond("neophytos");

  cout << "first=" << thePair.getFirst() << " second=" << thePair.getSecond() << endl;

  MyPair<int,string> otherPair;
  otherPair.setFirst(888);
  otherPair.setSecond("demetriou");

  thePair.swap(otherPair);

  cout << "(after swap) first=" << thePair.getFirst() << " second=" << thePair.getSecond() << endl;

  return 0;
}
