#include <iostream>
#include <string>


using namespace std;


template <typename T> class SmartPointer
{
public:
  explicit SmartPointer(T* memory);
  SmartPointer(const SmartPointer& other);
  SmartPointer& operator =(const SmartPointer& other);
  ~SmartPointer();

  T& operator *  () const;
  T* operator -> () const;

  T*     get() const;
  size_t getShareCount() const;
  void   reset(T* newRes);

private:
  struct Intermediary
  {
    T* resource;
    size_t refCount;
  };
  Intermediary* data;

  void detach();
  void attach(Intermediary* other);
};


template <typename T> void SmartPointer<T>::detach()
{
  --data->refCount;
  if(data->refCount == 0) {
    delete data->resource;
    delete data;
  }
}


template <typename T> void SmartPointer<T>::attach(Intermediary* to)
{
  data = to;
  ++data->refCount;
}


template <typename T> SmartPointer<T>::SmartPointer(T* res)
{
  data = new Intermediary;
  data->resource = res;
  data->refCount = 1;
}


// copy constructor
template <typename T> SmartPointer<T>::SmartPointer(const SmartPointer& other)
{
  attach(other.data);
}


// assignment operator
template <typename T> SmartPointer<T>& SmartPointer<T>::operator=(const SmartPointer& other)
{
  if (this != &other) {
    detach();
    attach(other.data);
  }
  return *this;
}


template <typename T> SmartPointer<T>::~SmartPointer()
{
  detach();
}


template <typename T> T& SmartPointer<T>::operator * () const
{
  return *data->resource;
}


template <typename T> T* SmartPointer<T>::operator -> () const
{
  return data->resource;
}


template <typename T> T* SmartPointer<T>::get() const
{
  return data->resource;
}


template <typename T> size_t SmartPointer<T>::getShareCount() const
{
  return data->refCount;
}


template <typename T> void SmartPointer<T>::reset(T* newRes) 
{
  // We're no longer associated with our current resource, so drop it. */
  detach();

  /* Attach to a new intermediary object. */
  data = new Intermediary;
  data->resource = newRes;
  data->refCount = 1;

}


int main(int argc, char *argv[])
{
  SmartPointer<string> myPtr(new string);
  *myPtr = "this is a string!";
  cout << *myPtr << endl;

  SmartPointer<string> other = myPtr;
  cout << *other << endl;
  cout << other->length() << endl;

  return 0;
}
