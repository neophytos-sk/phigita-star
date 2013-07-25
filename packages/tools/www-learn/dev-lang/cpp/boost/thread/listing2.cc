// Listing 2 illustrates a very simple use of the boost::mutex class. Two new threads are created, which loop 10 times, writing out an id and the current loop count to std::cout, while the main thread waits for both to complete. The std::cout object is a shared resource, so each thread uses a global mutex to ensure that only one thread at a time attempts to write to it.

#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <iostream>

boost::mutex io_mutex;

struct count {
  count(int id) : id(id) { }
  void operator()() {
    for (int i = 0; i < 10; ++i) {
      boost::mutex::scoped_lock lock(io_mutex);
      std::cout << id << ": " << i << std::endl;
    }
  }
  int id;
};


int main(int argc, char *argv[]) {
  boost::thread thrd1(count(1));
  boost::thread thrd2(count(2));
  thrd1.join();
  thrd2.join();
  return 0;
}
