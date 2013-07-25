// Listing 5 illustrates a very simple use of the boost::thread_specific_ptr class. Two new threads are created to initialize the thread local storage and then loop 10 times incrementing the integer contained in the smart pointer and writing the result to std::cout (which is synchronized with a mutex because it is a shared resource). The main thread then waits for these two threads to complete. The output of this example clearly shows that each thread is operating on its own instance of data, even though both are using the same boost::thread_specific_ptr.

#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/tss.hpp>
#include <iostream>

boost::mutex io_mutex;
boost::thread_specific_ptr<int> ptr;

struct count
{
  count(int id) : id(id) { }

  void operator()()
  {
    if (ptr.get() == 0)
      ptr.reset(new int(0));

    for (int i = 0; i < 10; ++i)
    {
      (*ptr)++;
      boost::mutex::scoped_lock
        lock(io_mutex);
      std::cout << id << ": "
        << *ptr << std::endl;
    }
  }

  int id;
};

int main(int argc, char* argv[])
{
  boost::thread thrd1(count(1));
  boost::thread thrd2(count(2));
  thrd1.join();
  thrd2.join();
  return 0;
}
